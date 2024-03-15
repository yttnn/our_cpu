#!/bin/bash

iverilog -g2012 -DBENCH testbench_iverilog.sv top.sv memory.sv core.sv def.sv
vvp a.out
