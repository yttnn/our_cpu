module top();
  reg clk=0; initial #150 forever #1000 clk = ~clk;
  logic reset_n = 1;
  core _core (clk, reset_n);
    // initial #99 forever #100
      // $display("%3d %h %h", $time, core.r_pc, m.w_ir);
      // $display("%h", _core.pc);
  // initial #10000 $finish;
endmodule
