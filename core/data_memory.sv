module data_memory(
  input logic clk,
  input logic reset_n;
  input logic [31:0] addr,
  input logic read_enable,
  input logic write_enable,
  input logic [31:0] write_data,

  output logic [31:0] read_data,
);

  localparam DMEM_SIZE = 1024;
  logic [31:0] d_memory[0:DMEM_SIZE-1];

  assign read_data = (reset_n && read_enable) ? d_memory[addr] : 32'b0;

  integer i;
  initial begin
    for (i = 0; i < DMEM_SIZE; i++) begin
      d_memory[i] <= 0;
    end
  end

  always @(posedge clk) begin
    if (reset_n) begin
      if (write_enable) begin
        d_memory[addr] <= write_data;
      end
    end
  end

endmodule