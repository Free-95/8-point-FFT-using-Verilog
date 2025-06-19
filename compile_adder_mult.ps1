# Exit immediately if a command fails
$ErrorActionPreference = "Stop"



iverilog -g2012 -o outputs/sim.out bit_reverse_mapper.v posit16_adder.v twiddleROM.v fft8_posit_tb.v fft8_posit.v posit16_mult.v butterfly2p_posit.v cpx_mad_posit.v 

vvp outputs/sim.out

Start-Process "gtkwave.exe" "outputs/*.vcd"