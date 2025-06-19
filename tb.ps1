$ErrorActionPreference = "Stop"


iverilog -g2012 -o outputs/sim.out tb_posit16_mult.v posit16_mult.v posit16_adder.v

vvp outputs/sim.out

iverilog -g2012 -o outputs/sim.out tb_posit16_adder.v posit16_adder.v

vvp outputs/sim.out