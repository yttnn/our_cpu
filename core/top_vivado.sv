module top_vivado(
  input logic CLK,
  input logic RESET,

  output logic [3:0] led
);

  logic divided_clk;
  clock_divider _clock_divider(
    .CLK(CLK),
    .divided_clk(divided_clk)
  );

  logic [31:0] debug_signal;
  logic [31:0] debug_status;

  top _top(
    .clk(divided_clk),
    .reset_n(!RESET),
    .debug_signal(debug_signal),
    .debug_status(debug_status)
  );
endmodule