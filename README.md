# ECE 410/510 — Hardware for AI/ML (HW4AI) Spring 2026

**Student:** [Your Name]  
**Course:** ECE 410/510 Spring 2026 — Hardware for Artificial Intelligence and Machine Learning  
**Instructor:** Christof Teuscher, Portland State University

---

## Tentative Project Topic

**INT8 Systolic Array MAC Accelerator for CNN Inference**

Designing a pipelined, synthesizable INT8 multiply-accumulate (MAC) accelerator targeting the `Conv2D._im2col` bottleneck identified through profiling. The accelerator uses symmetric per-tensor quantization and tiled shared-memory access to raise arithmetic intensity from ~1.74 FLOP/byte (CPU baseline) to ~25 FLOP/byte, moving the dominant kernel from memory-bound to compute-bound on the target hardware.

---

## Repository Structure

```
codefest/
  cf01/
    cman/cman_workload_accounting.md   — Workload accounting for 3-layer FC network
    profiling/resnet18_profile.txt     — torchinfo output for ResNet-18
    profiling/resnet18_analysis.md     — Top-5 MAC layers + arithmetic intensity
  cf02/
    cman/cman_roofline.md              — Roofline construction + kernel classification
    profiling/project_profile.txt      — cProfile output, Conv2D._im2col dominant
    profiling/roofline_cman.png        — CMAN roofline diagram
    profiling/roofline_project.png     — Project roofline (SW + HW design point)
    analysis/ai_calculation.md         — Arithmetic intensity for dominant kernel
    analysis/partition_rationale.md    — HW/SW partition proposal (200+ words)
  cf03/
    cman/cman_dram_traffic.md          — Naive vs. tiled DRAM traffic analysis
    cuda/gemm_naive.cu                 — Naive CUDA GEMM kernel (nvcc compilable)
    cuda/gemm_tiled.cu                 — Tiled CUDA GEMM kernel, T=8 (nvcc compilable)
    profiling/gemm_roofline.png        — Roofline with both GEMM kernels plotted
    analysis/gemm_analysis.md          — 150+ word analysis (naive, tiling, bottleneck)
    copt/nn_forward_gpu.py             — Neural network forward pass on GPU
    copt/copt_output.txt               — Terminal output confirming GPU execution
  cf04/
    cman_quantization.md               — INT8 symmetric quantization by hand
    hdl/mac_llm_A.v                    — MAC unit from Claude Sonnet 4.6
    hdl/mac_llm_B.v                    — MAC unit from GPT-4o
    hdl/mac_correct.v                  — Corrected MAC unit (compiles + passes testbench)
    hdl/mac_tb.v                       — Verilog testbench (all 6 assertions pass)
    review/mac_code_review.md          — Code review: issues, quoted lines, corrections

project/
  heilmeier_draft.md                   — Heilmeier Q1–Q3 (CF1 draft)
  heilmeier.md                         — Updated Heilmeier with profiling data (CF2+)
  algorithm_diagram.png                — Block diagram of target algorithm
  hdl/                                 — (Project HDL, populated in Milestone 2)
```

---

## HDL Module: `mac_correct.v`

**Module:** `mac`  
**Interface:** AXI4-Stream compatible (future); currently direct port I/O  
**Precision:** INT8 inputs (signed 8-bit), INT32 accumulator (signed 32-bit)  
**Interface choice justification:** The dominant kernel (`Conv2D._im2col`) has an interface bandwidth requirement of ~575 MB/s at 1 GFLOP/s throughput (AI = 1.74 FLOP/byte). An AXI4-Stream interface at 512-bit width / 500 MHz provides ~32 GB/s, far exceeding this requirement and leaving headroom for batched tile transfers. SPI (max ~50 MB/s) would create an interface bottleneck; AXI avoids this.

**To simulate:**
```bash
iverilog -g2012 -o sim mac_correct.v mac_tb.v && ./sim
```

Expected output:
```
PASS cycle 1: out=12
PASS cycle 2: out=24
PASS cycle 3: out=36
PASS reset: out=0
PASS cycle 5: out=-10
PASS cycle 6: out=-20
All tests PASSED.
```
