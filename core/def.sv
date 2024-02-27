`ifndef _parameters_state_
 `define _parameters_state_

typedef struct packed {
  logic [31:0] imm;

  logic lw;
  logic add;
  logic sub;
  logic addi;
} instinfo_t;

typedef enum logic[1:0] {
  FETCH,
  DECODE,
  EXECUTE
} state_t;

`endif