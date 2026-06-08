# Project Milestone 4 README
ECE 410/510 HW4AI Spring 2026

## Project: INT8 MAC Accelerator for CNN Inference

This is the final milestone. M1, M2, and M3 files are still present at their original paths.

## File Catalog

| File | Description | Checklist item |
|------|-------------|----------------|
| rtl/top.sv | Final integrated top module (same as M3) | Section 2 |
| rtl/compute_core.sv | INT8 MAC compute core (same as M2) | Section 2 |
| rtl/interface.sv | PCIe register-map interface (same as M2) | Section 2 |
| tb/tb_top.sv | Final end-to-end testbench (same as M3) | Section 2 |
| sim/final_run.log | Final simulation transcript showing PASS | Section 2 |
| sim/final_waveform.png | End-to-end waveform annotated | Section 2 |
| synth/config.json | OpenLane 2 configuration | Section 3 |
| synth/openlane_run.log | Full OpenLane run log | Section 3 |
| synth/timing_report.txt | STA report: WNS=-0.31ns at 100MHz | Section 3 |
| synth/area_report.txt | Area: 521.3 um^2, 112 cells | Section 3 |
| synth/power_report.txt | Power: 0.175 mW total | Section 3 |
| bench/benchmark.md | SW vs HW benchmark with speedup | Section 4 |
| bench/benchmark_data.csv | Raw benchmark numbers | Section 4 |
| bench/roofline_final.png | Final roofline with measured accelerator point | Section 4 |
| report/design_justification.pdf | 9-section design justification report | Section 5 |
| report/figures/ | All figures referenced in the report | Section 5 |

## How to Run Simulation

Simulator: Icarus Verilog 12.0
Command:
  iverilog -g2012 -o sim project/m2/rtl/compute_core.sv project/m2/rtl/interface.sv project/m3/rtl/top.sv project/m4/tb/tb_top.sv && ./sim

## OpenLane 2

Version: OpenLane 2.0.0
Config: project/m4/synth/config.json
Command: python3 -m openlane project/m4/synth/config.json
