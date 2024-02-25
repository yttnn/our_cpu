module instruction_memory (
  input logic [31:0] addr,
  output logic [31:0] inst
);

  localparam IMEM_SIZE = 1024;
  logic [31:0] i_memory[0:IMEM_SIZE-1];
  // inst = {i_memory[addr+3], i_memory[addr+2], i_memory[addr+1], i_memory[addr]};
  assign inst = i_memory[addr];

  initial begin
    i_memory[0] <= 32'b00000000001000001000000000110011; // add
  end
  
endmodule