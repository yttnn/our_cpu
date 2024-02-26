`include "def.sv"

module core (
  input logic clk,
  input logic reset_n
);
  
  logic [31:0] pc = 0;
  logic [31:0] registers[31:0];
  logic [31:0] data;
  logic [31:0] inst;
  
  // IF

  instruction_memory _instruction_memory(.addr(pc), .inst(inst));

  // ID
  // wire [6:0] funct7   = inst[31:25];
  // wire [4:0] rs2_addr = inst[24:20];
  // wire [4:0] rs1_addr = inst[19:15];
  // wire [2:0] funct3   = inst[14:12];
  // wire [4:0] rd       = inst[11:7];
  // wire [6:0] opcode  = inst[6:0];

 
  // wire [11:0] imm_i = inst[31:20];
  // wire [31:0] imm_i_sext = {{20{imm_i[11]}}, imm_i};
  // wire [11:0] imm_s = {inst[31:25], inst[11:7]};
  // wire [12:0] imm_b = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // imm_b[0] = 0 ????
  // wire [31:0] imm_u = {inst[31:12], 12'b0};
  // wire [20:0] imm_j = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
  instinfo_t instinfo;
  wire [4:0] rs1_addr;
  wire [4:0] rs2_addr;
  decode _decode(
    .clk(clk), .reset_n(reset_n), .inst_raw(inst),
    .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .instinfo(instinfo)
  );

  wire [31:0] rs1_data = (rs1_addr != '0) ? registers[rs1_addr] : '0;
  wire [31:0] rs2_data = (rs2_addr != '0) ? registers[rs2_addr] : '0;

  // instructions decode_inst;

  // always @(posedge clk) begin
  //   decode_inst.add <= ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000));
  // end

  // EX
  wire [31:0] alu_out;
  alu _alu(
    .clk(clk), .reset_n(reset_n), .instinfo(instinfo),
    .op1_data(rs1_data), .op2_data(rs2_data),
    .alu_out(alu_out)
  );
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
    $display("PC %d", pc);
    pc = pc + 1;
  end

endmodule