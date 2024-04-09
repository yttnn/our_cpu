module testbench_iverilog();
  reg clk=0; initial #150 forever #1000 clk = ~clk;
  logic reset_n = 1;
  logic [31:0] debug_signal;
  logic [31:0] debug_status;
  top _top(clk, reset_n, debug_signal, debug_status);

  always @(posedge debug_status[0]) begin
    $display("gp=%0d", debug_signal);
    $finish();
  end

endmodule
