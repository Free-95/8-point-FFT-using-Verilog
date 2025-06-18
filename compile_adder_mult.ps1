# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

iverilog -g2012 -o sim.out tb_posit16_mult.v posit16_mult.v

vvp sim.out

iverilog -g2012 -o sim.out tb_posit16_adder.v posit16_adder.v

vvp sim.out

iverilog -g2012 -o sim.out top.v butterfly.v cpx_mad.v bit_reverse_mapper.v float_adder float_multi twiddleROM

vvp sim.out