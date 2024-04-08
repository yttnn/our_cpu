module clock_divider (
  input logic CLK,
  
  output logic divided_clk
);

  parameter divide_value = 0;
  logic [divide_value:0] SLOW_CLK = 0;
  always @(posedge CLK) begin
    SLOW_CLK <= SLOW_CLK + 1;
  end

  assign divided_clk = SLOW_CLK[divide_value];

endmodule