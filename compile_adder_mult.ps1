# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

iverilog -g2012 -o outputs/sim.out tb_posit16_mult.v posit16_mult.v

vvp outputs/sim.out

iverilog -g2012 -o outputs/sim.out tb_posit16_adder.v posit16_adder.v

vvp outputs/sim.out

iverilog -g2012 -o outputs/sim.out butterfly2p.v cpx_mad.v bit_reverse_mapper.v float_adder.v float_multi.v twiddleROM.v fft8_tb.v fft8_fp.v

vvp outputs/sim.out

Start-Process "gtkwave.exe" "outputs/*.vcd"