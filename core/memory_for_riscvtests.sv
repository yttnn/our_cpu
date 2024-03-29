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

  string input_file;
  initial begin
    if (!$value$plusargs("INPUT_FILE=%s", input_file)) begin
      $display("INPUT_FILE argument not found");
      $finish();
    end
    $readmemh(input_file, ROM);
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
    // $readmemh("../riscv-tests/hex/rv32ui-p-sw.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-xor.hex", ROM);
    // $readmemh("../riscv-tests/hex/rv32ui-p-xori.hex", ROM);
  end


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