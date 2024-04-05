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

  logic [31:0] MEM [0:4095];
  // localparam start = 32'h00000000;
  logic [7:0] ROM [0: 16384];
  integer i;
  initial begin
    for (i = 0; i<4096; i++) begin
      MEM[i] = 32'h0;
    end
    // MEM[0] = {32'h22222222};
    // ROM[0] = {8'h03};
    // ROM[1] = {8'h23};
    // ROM[2] = {8'h00};
    // ROM[3] = {8'h00};
    // ROM[4] = {8'h11};
    // ROM[5] = {8'h12};
    // ROM[6] = {8'h13};
    // ROM[7] = {8'h14};
    // $readmemh("../riscv-tests/hex/rv32ui-p-add.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-addi.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-and.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-andi.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-auipc.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-beq.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-bge.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-bgeu.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-blt.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-bltu.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-bne.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-fence_i.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-jal.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-jalr.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-lb.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-lbu.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-lh.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-lhu.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-lui.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-lw.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-ma_data.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-or.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-ori.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-sb.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-sh.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-simple.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-sll.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-slli.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-slt.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-slti.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-sltiu.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-sltu.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-sra.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-srai.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-srl.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-srli.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-sub.hex", ROM);
    $readmemh("../riscv-tests/hex/rv32ui-p-sw.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-xor.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-xori.hex", ROM);
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