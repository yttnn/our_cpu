module memory (
  input logic clk,
  input logic [31:0] mem_addr,
  input logic mem_r_enable,

  output logic [31:0] mem_rdata
);

  logic [31:0] MEM [0:255];

  `include "riscv_assembly.sv"
  
  integer L0_ = 8;
  initial begin
    ADD(x1, x0, x0);
    ADDI(x2, x0, 31);
    Label(L0_);
    ADDI(x1, x1, 1);
    BNE(x1, x2, LabelRef(L0_));
    EBREAK();
    endASM();
  end

  always @(posedge clk) begin
    if (mem_r_enable) begin
      mem_rdata <= MEM[mem_addr[31:2]];
    end
  end

endmodule