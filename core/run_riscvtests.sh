#!/bin/bash

tests=(
  "rv32ui-p-add" "rv32ui-p-addi" "rv32ui-p-and" "rv32ui-p-andi" "rv32ui-p-auipc"
  "rv32ui-p-beq" "rv32ui-p-bge" "rv32ui-p-bgeu" "rv32ui-p-blt" "rv32ui-p-bltu" "rv32ui-p-bne"
  "rv32ui-p-fence_i"
  "rv32ui-p-jal" "rv32ui-p-jalr"
  "rv32ui-p-lb" "rv32ui-p-lbu" "rv32ui-p-lh" "rv32ui-p-lhu" "rv32ui-p-lui" "rv32ui-p-lw"
  "rv32ui-p-ma_data"
  "rv32ui-p-or" "rv32ui-p-ori"
  "rv32ui-p-sb" "rv32ui-p-sh" "rv32ui-p-simple"
  "rv32ui-p-sll" "rv32ui-p-slli" "rv32ui-p-slt" "rv32ui-p-slti" "rv32ui-p-sltiu" "rv32ui-p-sltu"
  "rv32ui-p-sra" "rv32ui-p-srai" "rv32ui-p-srl" "rv32ui-p-srli"
  "rv32ui-p-sub" "rv32ui-p-sw"
  "rv32ui-p-xor" "rv32ui-p-xori"
)

iverilog -g2012 -DBENCH testbench_iverilog.sv top.sv memory_for_riscvtests.sv core.sv def.sv

for test_case in "${tests[@]}"
do
  testfile="../riscv-tests/hex/$test_case.hex"
  if [ ! -e $testfile ]; then
    echo "error: not found $test_case.hex from run_riscvtests.sh"
    continue
  fi

  exe_log=$(vvp a.out +INPUT_FILE=$testfile) # run simulation
  if [[ `echo $exe_log | grep 'PASS'` ]]; then
    echo "$test_case ... PASS"
  elif [[ `echo $exe_log | grep 'FAIL'` ]]; then
    echo "$test_case ... FAIL"
    echo "log : $exe_log"
  else
    echo "$test_case ... unexpected"
    echo "  log : $exe_log"
  fi
done
