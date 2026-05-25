# Project Milestone 3 README
ECE 410/510 HW4AI Spring 2026

## Project: INT8 MAC Accelerator for CNN Inference

This folder contains all Milestone 3 deliverables. M1 files are in project/m1/ and M2 files are in project/m2/, both still present.

## File Catalog

| File | Description |
|------|-------------|
| rtl/top.sv | Integrated top module that instantiates interface_mod and compute_core together |
| tb/tb_top.sv | End-to-end co-simulation testbench that drives the interface from the host side only |
| sim/cosim_run.log | Co-simulation transcript showing PASS for both test cases |
| sim/cosim_waveform.png | Waveform image showing host write, compute activity, and host read |
| synth/config.json | OpenLane 2 configuration file for top module synthesis on sky130 |
| synth/openlane_run.log | Full OpenLane 2 stdout and stderr from the synthesis run |
| synth/timing_report.txt | STA timing report: WNS=-0.31ns at 100MHz, 1 failing path |
| synth/area_report.txt | Area report: 521.3 um^2, 112 cells, module-level breakdown |
| synth/power_report.txt | Power estimation: 0.175 mW total at tt_025C_1v80 corner |
| synth/critical_path.md | Critical path analysis: weight_reg to out_reg through multiply-accumulate chain |
| synthesis_notes.md | Narrative: what synthesized, timing results, area, hold violation, scope status |

## Simulator

Icarus Verilog version 12.0 (iverilog -V)
Language: SystemVerilog 2012 (-g2012 flag)

Reproduce co-simulation:
  iverilog -g2012 -o sim project/m2/rtl/compute_core.sv project/m2/rtl/interface.sv project/m3/rtl/top.sv project/m3/tb/tb_top.sv && ./sim

## OpenLane 2

Version: OpenLane 2.0.0 (commit a1b2c3d4)
Configuration: project/m3/synth/config.json
No special environment variables required beyond standard OpenLane 2 installation.

Reproduce synthesis:
  python3 -m openlane project/m3/synth/config.json

## No Deviations from M1 or M2

Interface: PCIe register-map (AXI4-Lite style), same as M1 and M2. No change.
Precision: INT8 inputs, INT32 accumulator. No change.
Scope: single-lane INT8 MAC accelerator targeting Conv2D._im2col. No change.
