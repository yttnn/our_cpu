`include "def.sv"

module core (
  input logic clk,
  input logic reset_n,
  input logic [31:0] mem_rdata,
  input logic [31:0] rom_rdata,

  output logic [31:0] rom_addr,
  output logic [31:0] mem_addr,
  output logic mem_r_enable,
  output logic mem_w_enable,
  output logic [31:0] mem_wdata,
  output logic [31:0] x1 // for debug
);
  
  logic [31:0] pc = 0;
  logic [31:0] registers[31:0];
  logic [31:0] csr_regs[4095:0];
  `ifdef BENCH
  integer i;
  initial begin
    for (i=0; i<32; i++) begin
      registers[i] = 0;
    end
    for (i=0; i<4096; i++) begin
      csr_regs[i] = 0;
    end
  end
  `endif
  logic [31:0] inst;
  
  // ================================
  // DECODE
  // ================================
  wire [6:0] funct7   = inst[31:25];
  wire [4:0] rs2_addr = inst[24:20];
  wire [4:0] rs1_addr = inst[19:15];
  wire [2:0] funct3   = inst[14:12];
  wire [4:0] rd       = inst[11:7];
  wire [6:0] opcode   = inst[6:0];

  wire is_alu_reg = (opcode == 7'b0110011); // rd <- rs1 OP rs2
  wire is_alu_imm = (opcode == 7'b0010011); // rd <- rs1 OP imm_i
  wire is_branch  = (opcode == 7'b1100011); // B type
  wire is_jalr    = (opcode == 7'b1100111); // rd <- pc+4; pc <- rs1+imm_i
  wire is_jal     = (opcode == 7'b1101111); // rd <- pc+4; pc <- pc+imm_j
  wire is_auipc   = (opcode == 7'b0010111); // rd <- pc+imm_u
  wire is_lui     = (opcode == 7'b0110111); // rd <- imm_u
  wire is_load    = (opcode == 7'b0000011); // rd <- mem[rs1+imm_i]
  wire is_store   = (opcode == 7'b0100011); // mem[rs1+imm_s] <- rs2
  wire is_system  = (opcode == 7'b1110011); // system call
  wire is_csr     = (is_system && (funct3 != 3'b000 && funct3 != 3'b100));
  wire is_ecall   = (is_system && inst[31:7] == {25'b0});
 
  wire [11:0] imm_i = inst[31:20];
  wire [11:0] imm_s = {inst[31:25], inst[11:7]};
  wire [12:0] imm_b = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
  wire [31:0] imm_u = {inst[31:12], 12'b0};
  wire [20:0] imm_j = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
  wire [ 4:0] imm_z = inst[19:15];
  wire [31:0] imm_i_sign_ext = {{20{imm_i[11]}}, imm_i};
  wire [31:0] imm_s_sign_ext = {{20{imm_s[11]}}, imm_s};
  wire [31:0] imm_b_sign_ext = {{19{imm_b[12]}}, imm_b};
  wire [31:0] imm_u_sign_ext = {imm_u};
  wire [31:0] imm_j_sign_ext = {{11{imm_j[20]}}, imm_j};
  wire [31:0] imm_z_usign_ext = {27'b0, imm_z};

  state_t state = FETCH;
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;

  wire [31:0] load_store_addr = rs1_data + (is_store ? imm_s_sign_ext : imm_i_sign_ext);
  wire [15:0] load_halfword = load_store_addr[1] ? mem_rdata[31:16] : mem_rdata[15:0];
  wire [7:0] load_byte = load_store_addr[0] ? load_halfword[15:8] : load_halfword[7:0];
  wire load_sign = !funct3[2] & (is_mem_byte_access ? load_byte[7] : load_halfword[15]); // 符号
  wire is_mem_byte_access = (funct3[1:0] == 2'b00);
  wire is_mem_halfword_access = (funct3[1:0] == 2'b01);
  wire [31:0] load_data = is_mem_byte_access ? {{24{load_sign}}, load_byte} :
                           is_mem_halfword_access ? {{16{load_sign}}, load_halfword} :
                           mem_rdata;

  // ===========================
  // ALU
  // ===========================  
  wire [31:0] alu_in_1 = rs1_data;
  wire [31:0] alu_in_2 = is_alu_reg ? rs2_data : imm_i_sign_ext;
  wire [4:0] shift_amount = is_alu_reg ? rs2_data[4:0] : imm_i_sign_ext[4:0];
  logic [31:0] alu_out;
  always @(*) begin // TODO: change to always_comb
    case (funct3)
      3'b000 : alu_out = (funct7[5] & opcode[5]) ? (alu_in_1 - alu_in_2) : (alu_in_1 + alu_in_2);
      3'b001 : alu_out = alu_in_1 << shift_amount;
      3'b010 : alu_out = ($signed(alu_in_1) < $signed(alu_in_2));
      3'b011 : alu_out = (alu_in_1 < alu_in_2);
      3'b100 : alu_out = (alu_in_1 ^ alu_in_2);
      3'b101 : alu_out = funct7[5] ? ($signed(alu_in_1) >>> shift_amount) : ($signed(alu_in_1) >> shift_amount);
      3'b110 : alu_out = (alu_in_1 | alu_in_2);
      3'b111 : alu_out = (alu_in_1 & alu_in_2);
      default: ;
    endcase
  end

  // ===========================
  // BRANCH
  // ===========================
  logic [31:0] take_branch;
  always @(*) begin // TODO: change to always_comb
    case (funct3)
      3'b000 : take_branch = (rs1_data == rs2_data); // beq
      3'b001 : take_branch = (rs1_data != rs2_data); // bne
      3'b100 : take_branch = ($signed(rs1_data) < $signed(rs2_data)); // blt
      3'b101 : take_branch = ($signed(rs1_data) >= $signed(rs2_data)); // bge
      3'b110 : take_branch = (rs1_data < rs2_data); // bltu
      3'b111 : take_branch = (rs1_data >= rs2_data); // bgeu
      default: take_branch = 1'b0;
    endcase
  end
  
  // ============================
  // CSR
  // ============================
  wire [11:0] csr_addr = is_ecall ? 12'h342 : inst[31:20];
  wire [31:0] csr_rdata = csr_regs[csr_addr];
  logic [31:0] csr_wdata;
  always @(*) begin
    case (funct3)
      3'b001 : csr_wdata = rs1_data; // csrrw
      3'b101 : csr_wdata = imm_z_usign_ext; // csrrwi
      3'b010 : csr_wdata = csr_rdata | rs1_data; // csrrs
      3'b110 : csr_wdata = csr_rdata | imm_z_usign_ext; // csrrsi
      3'b011 : csr_wdata = csr_rdata & ~rs1_data; // csrrc
      3'b111 : csr_wdata = csr_rdata & ~imm_z_usign_ext; // csrrci
      // ------------ ecall -----------------------
      3'b000 : csr_wdata = 32'd11; // ecall from machine mode
      default : csr_wdata = 1'b0;
    endcase
  end

  // ====================
  // WRITE BACK
  // ====================
  wire [31:0] wb_data = (is_jal || is_jalr) ? (pc + 4) :
                        (is_lui)            ? imm_u_sign_ext :
                        (is_auipc)          ? (pc + imm_u_sign_ext) :
                        (is_csr)            ? csr_rdata :
                        (is_load)           ? load_data :
                        alu_out;
  wire wb_enable = (
    state == WB &&
    (
      is_alu_reg ||
      is_alu_imm ||
      is_jal     ||
      is_jalr    ||
      is_lui     ||
      is_csr ||
      is_load ||
      is_auipc
    )
  );
  // TODO: def mtvec(32'h305)
  wire [31:0] next_pc = (is_branch && take_branch) ? pc + imm_b_sign_ext :
                        is_jal                     ? pc + imm_j_sign_ext :
                        is_jalr                    ? rs1_data + imm_i_sign_ext :
                        is_ecall                   ? csr_regs[32'h305] : // jump to mtvec(trap_vector)
                        pc + 4;

  // =======================
  // MEMORY
  // =======================
  // FIX: ROM impl
  // assign mem_addr = (state == WAIT_INSTR || state == FETCH) ? pc : load_store_addr;
  assign mem_addr = load_store_addr;
  assign rom_addr = pc;
  // assign mem_r_enable = (state == FETCH || (state == MEM_ACCESS && is_load));
  assign mem_r_enable = (state == MEM_ACCESS && is_load);
  assign mem_w_enable = ((state == MEM_ACCESS) && is_store);
  assign mem_wdata = rs2_data;

  always @(posedge clk ) begin
    if (!reset_n) begin
      pc <= 0;
      state <= FETCH;
    end
    else begin // reset_n == true

      case (state)
        FETCH : begin
          `ifdef BENCH
          if (pc === 'x) begin
            $display("error: unexpected value in pc");
            $finish();
          end
          `endif
          state <= WAIT_INSTR;
        end
        WAIT_INSTR : begin
          // FIX ROM impl
          // inst <= mem_rdata;
          inst <= rom_rdata;
          state <= DECODE;
        end
        DECODE : begin
          rs1_data <= registers[rs1_addr];
          rs2_data <= registers[rs2_addr];
          state <= EXECUTE;
        end
        EXECUTE : begin
          state <= MEM_ACCESS;
          `ifdef BENCH
          // FIX: riscv-tests finish flag
          if (pc == 32'h4c) begin
            if (registers[3] == 1) begin $display("PASS"); end
            else                   begin $display("FAIL"); end
            $display("gp=%h", registers[3]);
            $finish();
          end
          `endif
        end
        MEM_ACCESS : begin
          if (is_csr || is_ecall) begin
            csr_regs[csr_addr] <= csr_wdata;
          end
          `ifdef DEBUG
          if (is_store) begin
            $display("store mem[%h]=%h", load_store_addr, mem_wdata);
          end
          `endif
          state <= WB;
        end
        WB : begin
          if (wb_enable && rd != 0) begin
            registers[rd] <= wb_data;
            `ifdef DEBUG
            if (is_load) begin
              $display("mem[%h]=%h", load_store_addr, load_data);
              $display("wbdata=%h", wb_data);
            end
            `endif
          end
          // $display("mem[%h]=%h", load_store_addr, load_data);
          // $display("wbdata=%h", wb_data);
          pc <= next_pc;
          state <= FETCH;
        end
        default: $display("warning: switch state. core.sv");
      endcase

    end // reset_n == true
  end

  // debug output
  `ifdef DEBUG
  always @(posedge clk) begin
    if (state == DECODE) begin
    // $display("PC=%0d", pc);
    $display("pc=%h, gp=%d, ra=%h, sp=%h, a4=%h, a5=%h, t2=%h", pc, registers[3], registers[1], registers[2], registers[14], registers[15], registers[7]);
    case (1'b1)
      is_alu_reg : $display("alu_reg rd=%d, rs1=%d, rs2=%d, funct3=%b", rd, rs1_addr, rs2_addr, funct3);
      is_alu_imm : $display("alu_imm rd=%d, rs1=%d, imm=%d, funct3=%b", rd, rs1_addr, rs2_addr, funct3);
      is_branch  : $display("branch rs1=%0d rs2=%0d", rs1_addr, rs2_addr);
      is_jal     : $display("jal");
      is_jalr    : $display("jalr");
      is_auipc   : $display("auipc %h", imm_u_sign_ext);
      is_lui     : $display("lui");
      is_load    : $display("load");
      is_store   : $display("store");
      // is_system  : $display("system pc =%h", pc);
      is_csr     : $display("csr pc=%h csrw=%h csrr=%h", pc, csr_wdata, csr_rdata);
      is_ecall   : $display("ecall pc=%h", pc);
      default    : $display("??????");
    endcase

    end
  end
  `endif

endmodule