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
  
  // IF

  // instruction_memory _instruction_memory(.addr(pc), .inst(inst));

  // ID
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
  // instinfo_t instinfo;
  // wire [4:0] rs1_addr;
  // wire [4:0] rs2_addr;
  // decode _decode(
  //   .clk(clk), .reset_n(reset_n), .inst_raw(inst),
  //   .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .instinfo(instinfo)
  // );

  // wire [31:0] rs1_data = (rs1_addr != '0) ? registers[rs1_addr] : '0;
  // wire [31:0] rs2_data = (rs2_addr != '0) ? registers[rs2_addr] : '0;

  // instructions decode_inst;

  // always @(posedge clk) begin
  //   decode_inst.add <= ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000));
  // end

  // EX
  // wire [31:0] alu_out;
  // alu _alu(
  //   .clk(clk), .reset_n(reset_n), .instinfo(instinfo),
  //   .op1_data(rs1_data), .op2_data(rs2_data),
  //   .alu_out(alu_out)
  // );
  // always @(posedge clk) begin
  //   $display("%b", inst);
    // decode_inst.add = ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000));
    // decode_inst.sub = ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000));
    // decode_inst.addi = ((opcode == 7'b0010011) && (funct3 == 3'b000));
  //   if (decode_inst.add) begin
  //     registers[rd] = rs1_data + rs2_data;
  //     $display("add");
  //   end
  //   else if (decode_inst.sub) begin
  //     registers[rd] = rs1_data - rs2_data;
  //   end
  //   else if (decode_inst.addi) begin
  //     registers[rd] = rs1_data + imm_i_sext;
  //   end
  //   pc = pc + 1;
  // end

  always @(posedge clk ) begin
    if (!reset_n) begin
      pc <= 0;
    end
    else if (!is_system) begin
      inst <= mem[pc];
      pc <= pc + 1;
    end
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