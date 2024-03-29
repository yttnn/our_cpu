#!/bin/bash

tests=(
  "rv32ui-p-add" "rv32ui-p-addi" "rv32ui-p-and" "rv32ui-p-andi" "rv32ui-p-auipc"
  "rv32ui-p-beq" "rv32ui-p-bge" "rv32ui-p-bgeu" "rv32ui-p-blt" "rv32ui-p-bltu" "rv32ui-p-bne"
  "rv32ui-p-fence_i"
  "rv32ui-p-jal" "rv32ui-p-jalr"
)

iverilog -g2012 -DBENCH testbench_iverilog.sv top.sv memory_for_riscvtests.sv core.sv def.sv

for test_case in "${tests[@]}"
do
  echo "case : $test_case"
  testfile="../riscv-tests/hex/$test_case.hex"
  if [ ! -e $testfile ]; then
    echo "error: not found $test_case.hex from run_riscvtests.sh"
    continue
  fi

  exe_log=$(vvp a.out +INPUT_FILE=$testfile) # run simulation
  if [[ `echo $exe_log | grep 'PASS'` ]]; then
    echo "status : PASS"
  elif [[ `echo $exe_log | grep 'FAIL'` ]]; then
    echo "status : FAIL"
  else
    echo "status : unexpected"
    echo "log : $exe_log"
  fi
  echo "-------------"
done
