module core (
  input logic clk
  // input logic reset,
);
  
  logic [31:0] pc = 0;
  logic [31:0] registers[31:0];
  logic [31:0] data;
  logic [31:0] inst;
  
  always_comb begin
    case(inst)
      
    endcase
  end
  // IF

  // ID
  wire [6:0] funct7   = inst[31:25];
  wire [4:0] rs2_addr = inst[24:20];
  wire [4:0] rs1_addr = inst[19:15];
  wire [2:0] funct3   = inst[14:12];
  wire [4:0] rd       = inst[11:7];
  wire [6:0] opcode  = inst[6:0];

  wire [31:0] rs1_data = (rs1_addr != '0) ? registers[rs1_addr] : '0;
  wire [31:0] rs2_data = (rs2_addr != '0) ? registers[rs2_addr] : '0;

  always @(posedge clk ) begin
    pc = pc + 4;
  end

endmodule