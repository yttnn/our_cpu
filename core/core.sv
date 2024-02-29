`include "def.sv"

module core (
  input logic clk,
  input logic reset_n
);
  
  logic [31:0] pc = 0;
  logic [31:0] registers[31:0];
  `ifdef BENCH
  integer i;
  initial begin
    for (i=0; i<32; i++) begin
      registers[i] = 0;
    end
  end
  `endif
  logic [31:0] data;
  logic [31:0] inst;
  logic [31:0] MEM [0:255];

  `include "riscv_assembly.sv"
  initial begin
    ADD(x0,x0,x0);
    ADD(x1,x0,x0);
    ADDI(x1,x1,1);
    ADDI(x1,x1,1);
    ADDI(x1,x1,1);
    ADDI(x1,x1,1);
    ADD(x2,x1,x0);
    ADD(x3,x1,x2);
    SRLI(x3,x3,3);
    SLLI(x3,x3,31);
    SRAI(x3,x3,5);
    SRLI(x1,x3,26);
    EBREAK();
  end
  
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
 
  wire [11:0] imm_i = inst[31:20];
  wire [11:0] imm_s = {inst[31:25], inst[11:7]};
  wire [12:0] imm_b = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
  wire [31:0] imm_u = {inst[31:12], 12'b0};
  wire [20:0] imm_j = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
  wire [31:0] imm_i_sign_ext = {{20{imm_i[11]}}, imm_i};
  wire [31:0] imm_s_sign_ext = {{20{imm_s[11]}}, imm_s};
  wire [31:0] imm_b_sign_ext = {{19{imm_b[12]}}, imm_b};
  wire [31:0] imm_u_sign_ext = {imm_u};
  wire [31:0] imm_j_sign_ext = {{11{imm_j[20]}}, imm_j};

  state_t state = FETCH;
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;
  logic [31:0] wb_data;
  logic        wb_enable;

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
      3'b101 : alu_out = funct7[5] ? ($signed(alu_in_1) >>> shift_amount) : (alu_in_1 >> shift_amount);
      3'b110 : alu_out = (alu_in_1 | alu_in_2);
      3'b111 : alu_out = (alu_in_1 & alu_in_2);
      default: ;
    endcase
  end
  assign wb_data = alu_out;
  assign wb_enable = (state == EXECUTE && (is_alu_reg || is_alu_imm));

  always @(posedge clk ) begin
    if (!reset_n) begin
      pc <= 0;
      state <= FETCH;
    end
    else begin // reset_n == true
      if (wb_enable && rd != 0) begin
        registers[rd] <= wb_data;
        `ifdef BENCH
        $display("x[%0d] <= %b", rd, alu_out);
        `endif
      end

      case (state)
        FETCH : begin
          inst <= MEM[pc[31:2]];
          state <= DECODE;
        end
        DECODE : begin
          rs1_data <= registers[rs1_addr];
          rs2_data <= registers[rs2_addr];
          state <= EXECUTE;
        end
        EXECUTE : begin
          if (!is_system) begin
            pc <= pc + 4;
          end
          state <= FETCH;
        end
        default: $display("warning: switch state. core.sv");
      endcase

    end // reset_n == true
    `ifdef BENCH
    if (is_system) $finish();
    `endif
  end

  // debug output
  `ifdef BENCH
  always @(posedge clk) begin
    if (state == DECODE) begin
    // $display("PC=%0d", pc);

    case (1'b1)
      is_alu_reg : $display("alu_reg rd=%d, rs1=%d, rs2=%d, funct3=%b", rd, rs1_addr, rs2_addr, funct3);
      is_alu_imm : $display("alu_imm rd=%d, rs1=%d, imm=%d, funct3=%b", rd, rs1_addr, rs2_addr, funct3);
      is_branch  : $display("branch");
      is_jal     : $display("jal");
      is_jalr    : $display("jalr");
      is_auipc   : $display("auipc");
      is_lui     : $display("lui");
      is_load    : $display("load");
      is_store   : $display("store");
      is_system  : $display("system");
      default    : $display("??????");
    endcase

    $display("--------------");
    end
  end
  `endif

endmodule