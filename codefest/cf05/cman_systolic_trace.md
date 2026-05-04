# CMAN — 2×2 Weight-Stationary Systolic Array Trace
ECE 410/510 Codefest 5 — HW4AI Spring 2026

**Given:** A = [[1, 2], [3, 4]], B = [[5, 6], [7, 8]], expected C = [[19, 22], [43, 50]]

---

## (a) PE Diagram with Preloaded Weights

See `pe_diagram.png` for the full annotated diagram.

```
          Input (k=0)           Input (k=1)
          col stream →          col stream →

          ┌──────────────┐      ┌──────────────┐
          │  PE[0][0]    │ ───▶ │  PE[0][1]    │
          │ weight=B[0][0]│      │ weight=B[0][1]│
          │    = 5       │      │    = 6       │
          └──────┬───────┘      └──────┬───────┘
    psum ↓        │ psum ↓             │
          ┌──────▼───────┐      ┌──────▼───────┐
          │  PE[1][0]    │      │  PE[1][1]    │
          │ weight=B[1][0]│      │ weight=B[1][1]│
          │    = 7       │      │    = 8       │
          └──────────────┘      └──────────────┘
               ↓ C[·][0]             ↓ C[·][1]
```

**Preloaded weights (stay fixed throughout):**
- PE[0][0] = B[0][0] = **5**
- PE[0][1] = B[0][1] = **6**
- PE[1][0] = B[1][0] = **7**
- PE[1][1] = B[1][1] = **8**

---

## (b) Cycle-by-Cycle Trace

**Dataflow:** Inputs (A values) stream in from the left, skewed by one cycle per row. Partial sums flow **downward** within each column.

**Input skewing:** A[i][k] arrives at PE row k at cycle = i + k + 1

| Cycle | Input row k=0 | Input row k=1 | PE[0][0] partial | PE[0][1] partial | PE[1][0] partial | PE[1][1] partial | Output C |
|-------|---------------|---------------|-----------------|-----------------|-----------------|-----------------|----------|
| 1 | A[0][0]=1 | -- | 1x5=5(ps=5) | 1x6=6(ps=6) | 0(none) | 0(none) | -- |
| 2 | A[1][0]=3 | A[0][1]=2 | 3x5=15(ps=15) | 3x6=20(ps=18) | ps_in=5, 2x7=14 → 19=C[0][0] | ps_in=6, 2x8=16 → 22=C[0][1] | C- row0=[19,22] |
| 3 | -- | A[1][1]=4 | --(ps=15) | --(ps=18) | ps_in=15, 4x7=28 → 43=C[1][0] | ps_in=18, 4x8=32 → 50=C[1][1] | C-row1=[43,50] |
| 4 | (drain) | (drain) | -- | -- | -- | -- | -- |

**Note:** PE[0][1] partial shows ps=18 not 24; correct value is A[1][0]*B[0][1]=3x6=18.

---

## (c) Counts

### Total MACs
Total MACs = 2 x 2 x 2 = **8** (4 outputs x 2 multiplications each)

### Input Reuse
Each A[i][k] is used by 2 PEs (PE[k][0] and PE[k][1]) -> reused **2 times**

### Off-Chip Accesses

| Operand | Elements | Off-Chip Accesses |
|---------|----------|-------------------|
| A (inputs) | 4 | **4** (loaded once) |
| B (weights) | 4 | **4** (preloaded once) |
| C (outputs) | 4 | **4** (written once) |
| **Total** | | **12** |

---

## (d) Output-Stationary Answer

If output-stationary, the **C (partial sum) values would stay fixed in the PEs**, accumulating in place while both A inputs and B weights stream through the array.
