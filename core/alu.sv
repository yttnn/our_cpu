`include "def.sv"

module alu (
  input logic clk,
  input logic reset_n,
  input instinfo_t instinfo,
  input logic [31:0] op1_data,
  input logic [31:0] op2_data,

  output logic [31:0] alu_out
);

  assign alu_out = (reset_n) ? (
    instinfo.add  ? $signed(op1_data) + $signed(op2_data) :
    instinfo.sub  ? $signed(op1_data) - $signed(op2_data) :
    instinfo.addi ? $signed(op1_data) + $signed(instinfo.imm) :
    instinfo.lw   ? $signed(op1_data) + $signed(instinfo.imm) :
    32'b0 // default  
  ) : (32'b0); // !reset_n
  
endmodule