# GEMM Analysis

## Performance Comparison

The naive GEMM kernel performs matrix multiplication using global memory for every access. This leads to high DRAM traffic and low data reuse.

The tiled GEMM kernel uses shared memory to store tiles of A and B. This allows data reuse within each thread block and significantly reduces DRAM traffic.

## Arithmetic Intensity

Naive GEMM:
Low arithmetic intensity because each value is loaded many times from DRAM.

Tiled GEMM:
Higher arithmetic intensity because each tile is reused multiple times from shared memory.

## Performance Result

The tiled version runs significantly faster than the naive version. This is because it reduces memory traffic and increases data reuse.

## Roofline Interpretation

On the roofline model:
- The naive implementation is strongly memory-bound
- The tiled implementation moves closer to the ridge point

This means the tiled version better utilizes compute resources.

## Conclusion

Using shared memory tiling improves performance by reducing DRAM accesses and increasing arithmetic intensity. This optimization shifts the kernel closer to the compute-bound region.
