# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

iverilog -g2012 -o sim.out tb_bit_reverse_mapper.v bit_reverse_mapper.v

vvp sim.out

Start-Process "gtkwave.exe" "waveform.vcd"
