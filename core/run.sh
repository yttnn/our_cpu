#!/bin/bash

iverilog -g2012 -DBENCH -DDEBUG testbench_iverilog.sv top.sv memory.sv core.sv def.sv
vvp a.out
