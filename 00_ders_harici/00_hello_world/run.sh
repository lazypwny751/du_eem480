#!/bin/sh

set -e

SRC_DIR="src"
TB_DIR="tb"

[ ! -d "wave" ] && mkdir "wave"

echo "Analyzing..."
ghdl -a --std=08 "${SRC_DIR}/hello_world.vhd"
ghdl -a --std=08 "${TB_DIR}/hello_world_tb.vhd"

echo "Elaborating..."
ghdl -e --std=08 "hello_world_tb"

echo "Running simulation..."
ghdl -r --std=08 "hello_world_tb" --vcd="wave/output.vcd"

# echo "Opening GTKWave..."
# gtkwave "wave/output.vcd"
