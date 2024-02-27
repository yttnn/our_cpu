`include "def.sv"

module core (
  input logic clk,
  input logic reset_n
);
  
  logic [31:0] pc = 0;
  logic [31:0] registers[31:0];
  logic [31:0] data;
  logic [31:0] inst;
  logic [31:0] mem [0:255];

  initial begin
    // add x0, x0, x0
    //                   rs2   rs1  add  rd   ALUREG
    inst = 32'b0000000_00000_00000_000_00000_0110011;
    // add x1, x0, x0
    //                    rs2   rs1  add  rd  ALUREG
    mem[0] = 32'b0000000_00000_00000_000_00001_0110011;
    // addi x1, x1, 1
    //             imm         rs1  add  rd   ALUIMM
    mem[1] = 32'b000000000001_00001_000_00001_0010011;
    // addi x1, x1, 1
    //             imm         rs1  add  rd   ALUIMM
    mem[2] = 32'b000000000001_00001_000_00001_0010011;
    // addi x1, x1, 1
    //             imm         rs1  add  rd   ALUIMM
    mem[3] = 32'b000000000001_00001_000_00001_0010011;
    // addi x1, x1, 1
    //             imm         rs1  add  rd   ALUIMM
    mem[4] = 32'b000000000001_00001_000_00001_0010011;
    // lw x2,0(x1)
    //             imm         rs1   w   rd   LOAD
    mem[5] = 32'b000000000000_00001_010_00010_0000011;
    // sw x2,0(x1)
    //             imm   rs2   rs1   w   imm  STORE
    mem[6] = 32'b000000_00010_00001_010_00000_0100011;
    
    // ebreak
    //                                        SYSTEM
    mem[7] = 32'b000000000001_00000_000_00000_1110011;
    
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
  assign wb_data = 0;
  assign wb_enable = 0;

  always @(posedge clk ) begin
    if (!reset_n) begin
      pc <= 0;
      state <= FETCH;
    end
    else begin // reset_n == true
      if (wb_enable && rd != 0) begin
        registers[rd] <= wb_data;
      end

      case (state)
        FETCH : begin
          inst <= mem[pc];
          state <= DECODE;
        end
        DECODE : begin
          rs1_data <= registers[rs1_addr];
          rs2_data <= registers[rs2_data];
          state <= EXECUTE;
        end
        EXECUTE : begin
          if (!is_system) begin
            pc <= pc + 1;
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
    $display("PC=%0d", pc);

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
  `endif

endmodule