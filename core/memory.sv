module memory (
  input logic clk,
  input logic [31:0] mem_addr,
  input logic mem_r_enable,

  output logic [31:0] mem_rdata
);

  logic [31:0] MEM [0:255];

  `include "riscv_assembly.v"
  
  integer L0_ = 8;
  integer wait_ = 32;
  integer L1_ = 40;
  integer slow_bit = 13;
  initial begin
      LI(s0,0);   
      LI(s1,16);
   Label(L0_); 
      LB(a0,s0,400); // LEDs are plugged on a0 (=x10)
      CALL(LabelRef(wait_));
      ADDI(s0,s0,1); 
      BNE(s0,s1, LabelRef(L0_));
      EBREAK();
      
   Label(wait_);
      LI(t0,1);
      SLLI(t0,t0,slow_bit);
   Label(L1_);
      ADDI(t0,t0,-1);
      BNEZ(t0,LabelRef(L1_));
      RET();

      endASM();

      // Note: index 100 (word address)
      //     corresponds to 
      // address 400 (byte address)
      MEM[100] = {8'h4, 8'h3, 8'h2, 8'h1};
      MEM[101] = {8'h8, 8'h7, 8'h6, 8'h5};
      MEM[102] = {8'hc, 8'hb, 8'ha, 8'h9};
      MEM[103] = {8'hff, 8'hf, 8'he, 8'hd};     
  end

  always @(posedge clk) begin
    if (mem_r_enable) begin
      mem_rdata <= MEM[mem_addr[31:2]];
    end
  end

endmodule