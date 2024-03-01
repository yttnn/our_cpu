module testbench_iverilog();
  reg clk=0; initial #150 forever #1000 clk = ~clk;
  logic reset_n = 1;
  top _top(clk, reset_n);
endmodule
