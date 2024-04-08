module top(
  input logic clk,
  input logic reset_n
  // input logic rxd,
  
  // output logic txd,
  // output logic [4:0] leds
);
  logic [31:0] rom_addr;
  logic [31:0] rom_rdata;
  logic [31:0] mem_addr;
  logic [31:0] mem_rdata;
  logic [31:0] mem_wdata;
  logic mem_w_enable;
  logic mem_r_enable;
  logic [31:0] x1;

  logic cclk;
  clock_divider _clock_divider(
    .CLK(clk),
    .divided_clk(cclk)
  );

  memory _memory(
    .clk(cclk),
    .mem_addr(mem_addr),
    .mem_rdata(mem_rdata),
    .rom_addr(rom_addr),
    .rom_rdata(rom_rdata),
    .mem_r_enable(mem_r_enable),
    .mem_w_enable(mem_w_enable),
    .mem_wdata(mem_wdata)
  );

  core _core(
    .clk(cclk),
    .reset_n(reset_n),
    .mem_addr(mem_addr),
    .rom_addr(rom_addr),
    .rom_rdata(rom_rdata),
    .mem_rdata(mem_rdata),
    .mem_r_enable(mem_r_enable),
    .mem_w_enable(mem_w_enable),
    .mem_wdata(mem_wdata),
    .x1(x1)
  );
  
endmodule
