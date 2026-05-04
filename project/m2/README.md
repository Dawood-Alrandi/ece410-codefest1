# Project Milestone 2 - README
ECE 410/510 HW4AI Spring 2026

## Project: INT8 MAC Accelerator for CNN Inference

## How to Reproduce the M2 Simulation

Requirements: Icarus Verilog v12.0

Step 1 - Clone the repo:
  git clone https://github.com/Dawood-Alrandi/ece410-codefest1.git
  cd ece410-codefest1/project/m2
  mkdir -p sim

Step 2 - Run compute core simulation:
  iverilog -g2012 -o sim/compute_core_sim rtl/compute_core.sv tb/tb_compute_core.sv
  ./sim/compute_core_sim
  Expected: PASS: All compute_core tests passed.

Step 3 - Run interface simulation:
  iverilog -g2012 -o sim/interface_sim rtl/compute_core.sv rtl/interface.sv tb/tb_interface.sv
  ./sim/interface_sim
  Expected: PASS: All interface tests passed.

## Repository Structure

project/m2/rtl/compute_core.sv  - compute core HDL
project/m2/rtl/interface.sv      - interface module HDL
project/m2/tb/tb_compute_core.sv - compute core testbench
project/m2/tb/tb_interface.sv    - interface testbench
project/m2/sim/compute_core_run.log - simulation transcript
project/m2/sim/interface_run.log    - simulation transcript
project/m2/sim/waveform.png          - representative waveform
project/m2/precision.md              - numerical format analysis

## No Deviations from M1 Plan

Interface: PCIe (same as m1/interface_selection.md)
Precision: INT8 inputs, INT32 accumulator
Simulator: Icarus Verilog 12.0 (iverilog -V), SystemVerilog 2012 (-g2012)
