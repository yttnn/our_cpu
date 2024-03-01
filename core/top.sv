module top(
  input logic clk,
  input logic reset_n
  // input logic rxd,
  
  // output logic txd,
  // output logic [4:0] leds
);
  logic [31:0] mem_addr;
  logic [31:0] mem_rdata;
  logic mem_r_enable;
  logic [31:0] x1;

  memory _memory(
    .clk(clk),
    .mem_addr(mem_addr),
    .mem_rdata(mem_rdata),
    .mem_r_enable(mem_r_enable)
  );

  core _core(
    .clk(clk),
    .reset_n(reset_n),
    .mem_addr(mem_addr),
    .mem_rdata(mem_rdata),
    .mem_r_enable(mem_r_enable),
    .x1(x1)
  );
  
endmodule
