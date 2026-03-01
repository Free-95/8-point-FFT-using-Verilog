# 8-Point Radix-2 FFT using Verilog

This repository contains a hardware implementation of an 8-point Fast Fourier Transform (FFT) written in Verilog. It utilizes a Radix-2 Decimation-In-Time (DIT) algorithm and performs all computations using **IEEE-754 Half-Precision (FP16) floating-point arithmetic**. 

The project includes custom FP16 adders and multipliers, complex multiply-accumulate units, butterfly operators, and a MATLAB reference model for verifying hardware outputs.

## Features
* **Architecture:** 8-Point Radix-2 Decimation-in-Time (DIT) FFT.
* **Datapath:** 32-bit complex numbers (16-bit FP16 Real + 16-bit FP16 Imaginary).
* **Hexadecimal I/O:** Testbenches and MATLAB scripts are configured to input and output data as readable hexadecimal strings.
* **Verification:** Includes a complete set of testbenches for each sub-module and the top-level FFT module.
* **MATLAB Simulation:** Includes MATLAB scripts to encode/decode FP16 values and calculate the expected 8-point FFT for direct comparison against the Verilog output.

## Prerequisites
To simulate the design and verify the results, you will need:
1. **[Icarus Verilog (`iverilog`)](https://bleyer.org/icarus/)**: For compiling and running the Verilog testbenches.
2. **GTKWave**: For viewing the `.vcd` waveform files generated during simulation.
3. **[MATLAB](https://mathworks.com/help/install/ug/install-products-with-internet-connection.html)**: To run the reference `.mlx` Live Script.

## How to Run and Test

### 1. Generate Reference Data (MATLAB)
Open MATLAB, navigate to the `matlab/` directory, and run `fft8p.mlx`. 
This script will output the expected Time-Domain inputs and Frequency-Domain outputs as 8-character hexadecimal strings. You can plug these hex strings directly into the Verilog testbenches to verify functionality.

### 2. Run Verilog Simulations
Navigate to your project root directory in the terminal. You can compile and simulate any testbench using Icarus Verilog. 

For example, to test the top-level FFT module:
```bash
# Create an outputs directory if it doesn't exist to store waveforms
mkdir -p outputs

# Compile the design and testbench
iverilog -o outputs/top.out src/*.v test/top_tb.v

# Run the simulation
vvp outputs/top.out
```

*Note: The testbench will print the input and output arrays directly to the console in a readable format.*

### 3. View Waveforms

After running a simulation, a `.vcd` file will be generated in the `outputs/` folder. Open it using GTKWave:

```bash
gtkwave outputs/top.vcd

```

## Results

### MATLAB Reference Output

<img width="390" height="465" alt="image" src="https://github.com/user-attachments/assets/659a2d38-e3e2-471d-bcbb-128c85c2ca50" />


### Hardware Simulation Waveform

<img width="1598" height="172" alt="image" src="https://github.com/user-attachments/assets/9a56c1cf-e007-4ac3-942f-88046d187226" />

*Note: The first literal in every output represents the index, the actual 32-bit output starts after the index.*

---

*Developed using Verilog-2001 and MATLAB.*
