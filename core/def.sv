`ifndef _parameters_state_
 `define _parameters_state_

typedef struct packed {
  logic [31:0] imm;

  logic lw;
  logic add;
  logic sub;
  logic addi;
} instinfo_t;

typedef enum logic[2:0] {
  FETCH,
  WAIT_INSTR,
  DECODE,
  EXECUTE,
  MEM_ACCESS,
  WB
} state_t;

// parameter MCAUSE = 12'h342;
// parameter MTVEC  = 12'h305;

`endif