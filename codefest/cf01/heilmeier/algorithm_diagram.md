# Algorithm Diagram: INT8 Systolic Array MAC Accelerator
ECE 410/510 Codefest 1, HW4AI Spring 2026

## Block Diagram (text version)

```
Host CPU
|
| PCIe (AXI4-Lite register map)
|
+---v-------------------+
|   Interface Module    |
|   (interface.sv)      |
|   reg 0x00: write a,b |
|   reg 0x04: reset     |
|   reg 0x08: read out  |
+---v-------------------+
|
| valid_in, a[7:0], b[7:0]
|
+---v-------------------+
|   Compute Core        |
|   (compute_core.sv)   |
|                       |
|   product = a * b     |  <- signed 8-bit x 8-bit = 16-bit
|   acc += product      |  <- sign-extended to 32-bit
|                       |
|   out[31:0]           |  <- 32-bit accumulator
+---v-------------------+
|
| result
v
Host CPU reads acc_out via PCIe
```

## Dataflow

1. Host loads INT8 weight value into register b
2. Host loads INT8 activation value into register a
3. valid_in goes high for one clock cycle
4. Compute core multiplies a x b and adds to accumulator
5. After all MACs are done host reads the 32-bit accumulated result

## Why INT8

INT8 uses 4x less bandwidth than FP32. This raises arithmetic intensity from 1.06 to ~25 FLOP per byte. The roofline model shows this moves the kernel from memory-bound to compute-bound.
