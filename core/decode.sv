`include "def.sv"

module decode (
  input logic clk,
  input logic reset_n,
  input logic[31:0] inst_raw,

  output logic [4:0] rs1_addr,
  output logic [4:0] rs2_addr,
  output instinfo_t instinfo
);

  // decode
  wire [6:0] funct7   = inst_raw[31:25];
  wire [2:0] funct3   = inst_raw[14:12];
  wire [4:0] rd       = inst_raw[11:7];
  wire [6:0] opcode   = inst_raw[6:0];
  assign rs2_addr = inst_raw[24:20];
  assign rs1_addr = inst_raw[19:15];

  // immediate value
  wire [11:0] imm_i = inst_raw[31:20];
  wire [11:0] imm_s = {inst_raw[31:25], inst_raw[11:7]};
  wire [12:0] imm_b = {inst_raw[31], inst_raw[7], inst_raw[30:25], inst_raw[11:8], 1'b0}; // imm_b[0] = 0 ????
  wire [31:0] imm_u = {inst_raw[31:12], 12'b0};
  wire [20:0] imm_j = {inst_raw[31], inst_raw[19:12], inst_raw[20], inst_raw[30:21], 1'b0};
  // sign extension
  wire [31:0] imm_i_sext = {{20{imm_i[11]}}, imm_i};
  wire [31:0] imm_s_sext = {{20{imm_s[11]}}, imm_s};
  wire [31:0] imm_b_sext = {{19{imm_b[12]}}, imm_b};
  wire [31:0] imm_u_sext = {imm_u};
  wire [31:0] imm_j_sext = {{11{imm_j[20]}}, imm_j};

  // flags
  wire is_r_type = (opcode == 7'b0110011);

  always @(posedge clk) begin
    if (reset_n) begin
      instinfo.imm <= imm_i_sext;

      instinfo.add  <= ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000));
      instinfo.sub  <= ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000));
      instinfo.addi <= ((opcode == 7'b0010011) && (funct3 == 3'b000));

      $display("decode %b", inst_raw);
    end
  end
endmodule