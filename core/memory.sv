module memory (
  input logic clk,
  input logic [31:0] mem_addr,
  input logic mem_r_enable,
  input logic mem_w_enable,
  input logic [31:0] mem_wdata,
  input logic [31:0] rom_addr,

  output logic [31:0] rom_rdata,
  output logic [31:0] mem_rdata
);

  logic [31:0] MEM [0:255];
  // localparam start = 32'h00000000;
  logic [7:0] ROM [0: 16384];
  initial begin
    $readmemh("../riscv-tests/hex/rv32ui-p-add.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-auipc.hex", ROM);
  end

  `include "riscv_assembly.v"
  
  // integer L0_ = 16;
  // integer L1_ = 28;
  // integer L2_ = 52;
  // initial begin
  //   LI(t3, 10);
  //   LI(t4, 1);
  //   BLT(t4, t3, LabelRef(L0_));
  //   MV(t4, t3);
  //   Label(L0_);
  //   LI(t4, 1);
  //   LI(t5, 1);
  //   LI(t0, 2);
  //   Label(L1_);
  //   BGE(t0, t3, LabelRef(L2_));
  //   MV(t6, t4);
  //   ADD(t4, t4, t5);
  //   MV(t5, t6);
  //   ADDI(t0, t0, 1);
  //   J(LabelRef(L1_));
  //   Label(L2_);
  //   MV(a0, t4);
  //   EBREAK();
  //   endASM();

  //     // Note: index 100 (word address)
  //     //     corresponds to 
  //     // address 400 (byte address)
  //     MEM[100] = {8'h4, 8'h3, 8'h2, 8'h1};
  //     MEM[101] = {8'h8, 8'h7, 8'h6, 8'h5};
  //     MEM[102] = {8'hc, 8'hb, 8'ha, 8'h9};
  //     MEM[103] = {8'hff, 8'hf, 8'he, 8'hd};     
  // end

  assign rom_rdata = {ROM[rom_addr+3], ROM[rom_addr+2], ROM[rom_addr+1], ROM[rom_addr]};

  always @(posedge clk) begin
    if (mem_r_enable) begin
      mem_rdata <= MEM[mem_addr[31:2]];
    end
    else if (mem_w_enable) begin
      MEM[mem_addr] <= mem_wdata;
    end
  end

endmodule