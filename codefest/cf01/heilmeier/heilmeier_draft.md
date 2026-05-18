# Heilmeier Catechism Draft
ECE 410/510 Codefest 1, HW4AI Spring 2026

## What are you trying to do?

I am building a hardware accelerator that speeds up the convolution operation inside neural networks. Convolution is the most expensive part of running an image recognition model. My accelerator uses INT8 math instead of full precision floating point and processes multiply-accumulate operations in dedicated hardware instead of a general purpose CPU.

## How is it done today and what are the limits?

Today people run neural networks on CPUs and GPUs. CPUs are flexible but slow for this kind of work because they were not designed for millions of repeated multiply-add operations. From profiling I found that the convolution kernel takes about 70 percent of total runtime and has an arithmetic intensity of only 1.06 FLOP per byte, which means the CPU spends most of its time waiting for data from memory rather than doing math.

## What is your approach and why will it work?

My approach is to design a systolic array MAC unit in synthesizable SystemVerilog that uses INT8 weights and activations with a 32-bit accumulator. INT8 cuts the memory bandwidth by 4x compared to FP32, which raises arithmetic intensity from 1.06 to about 25 FLOP per byte. This crosses the roofline ridge point and moves the kernel from memory-bound to compute-bound on the target hardware. The design targets the SkyWater sky130 PDK at 100 MHz using a PCIe interface to connect to the host.

## How much will it cost and how long will it take?

This is a research prototype using open source tools (Yosys, Icarus Verilog, OpenLane 2) so there is no fabrication cost. The design and verification effort is one semester.

## What are the midterm and final exams?

Midterm: synthesizable RTL for the compute core and interface module with passing simulation.
Final: full synthesis with timing closure on sky130 and a comparison of measured throughput against the CPU baseline.
