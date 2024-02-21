module core (
  input logic clk
  // input logic reset,
);
  
  logic [31:0] pc = 0;
  logic [31:0] registers[31:0];
  logic [31:0] data;
  logic [31:0] inst;
  
  // IF

  // ID
  wire [6:0] funct7   = inst[31:25];
  wire [4:0] rs2_addr = inst[24:20];
  wire [4:0] rs1_addr = inst[19:15];
  wire [2:0] funct3   = inst[14:12];
  wire [4:0] rd       = inst[11:7];
  wire [6:0] opcode  = inst[6:0];

 
  wire [11:0] imm_i = inst[31:20];
  wire [31:0] imm_i_sext = {{20{imm_i[11]}}, imm_i};
  wire [11:0] imm_s = {inst[31:25], inst[11:7]};
  wire [12:0] imm_b = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // imm_b[0] = 0 ????
  wire [31:0] imm_u = {inst[31:12], 12'b0};
  wire [20:0] imm_j = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

  wire [31:0] rs1_data = (rs1_addr != '0) ? registers[rs1_addr] : '0;
  wire [31:0] rs2_data = (rs2_addr != '0) ? registers[rs2_addr] : '0;

  // EX
  always @(posedge clk) begin
    if ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000)) begin
      registers[rd] = rs1_data + rs2_data;
    end
  end

  always @(posedge clk ) begin
    pc = pc + 4;
  end

endmodule