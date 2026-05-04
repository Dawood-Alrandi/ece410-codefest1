      Input A values stream from the left
      Partial sums move downward

      ┌──────────────┐      ┌──────────────┐
      │  PE[0][0]    │ ───▶ │  PE[0][1]    │
      │ weight = 5   │      │ weight = 6   │
      └──────┬───────┘      └──────┬───────┘
             │                     │
             ▼                     ▼
      ┌──────────────┐      ┌──────────────┐
      │  PE[1][0]    │ ───▶ │  PE[1][1]    │
      │ weight = 7   │      │ weight = 8   │
      └──────┬───────┘      └──────┬───────┘
             │                     │
             ▼                     ▼
          C[ ][0]               C[ ][1]
          
Preloaded weights stay fixed throughout the computation:

- PE[0][0] = B[0][0] = 5
- PE[0][1] = B[0][1] = 6
- PE[1][0] = B[1][0] = 7
- PE[1][1] = B[1][1] = 8

---

## (b) Cycle-by-Cycle Trace

Dataflow:

Inputs A stream from the left.  
Inputs are skewed by one cycle per row.  
Partial sums move downward inside each column.  
Weights stay fixed inside each PE.

### Cycle 1

PE[0][0]: 1 x 5 = 5  
PE[0][1]: 1 x 6 = 6  

No output yet.

### Cycle 2

PE[0][0]: 3 x 5 = 15  
PE[0][1]: 3 x 6 = 18  
PE[1][0]: 5 + 2 x 7 = 19  
PE[1][1]: 6 + 2 x 8 = 22  

Output:

C[0] = [19, 22]

### Cycle 3

PE[1][0]: 15 + 4 x 7 = 43  
PE[1][1]: 18 + 4 x 8 = 50  

Output:

C[1] = [43, 50]

### Cycle 4

Drain cycle.  
No new MAC operation is needed.

---

## Complete Trace Table

| Cycle | Input to top row | Input to bottom row | PE[0][0] | PE[0][1] | PE[1][0] | PE[1][1] | Output |
|---|---|---|---|---|---|---|---|
| 1 | A[0][0] = 1 | -- | 1x5 = 5 | 1x6 = 6 | -- | -- | -- |
| 2 | A[1][0] = 3 | A[0][1] = 2 | 3x5 = 15 | 3x6 = 18 | 5 + 2x7 = 19 | 6 + 2x8 = 22 | C[0] = [19, 22] |
| 3 | -- | A[1][1] = 4 | -- | -- | 15 + 4x7 = 43 | 18 + 4x8 = 50 | C[1] = [43, 50] |
| 4 | drain | drain | -- | -- | -- | -- | Done |

---

## (c) Counts

### Total MAC Operations

There are 2 rows, 2 columns, and 2 multiply steps per output.

Total MACs = 2 x 2 x 2 = 8

So the total number of MAC operations is:

8 MACs

### Input Reuse

Each input A value is reused across 2 PEs in the row.

For example:

- A[0][0] = 1 is used with weights 5 and 6
- A[0][1] = 2 is used with weights 7 and 8
- A[1][0] = 3 is used with weights 5 and 6
- A[1][1] = 4 is used with weights 7 and 8

So each A value is reused 2 times.

### Off-Chip Memory Accesses

A inputs:

There are 4 A values.  
Each A value is loaded once.

A accesses = 4

B weights:

There are 4 B values.  
Each B value is preloaded once and then stays fixed in the PE.

B accesses = 4

C outputs:

There are 4 C values.  
Each output is written once.

C accesses = 4

Total off-chip accesses:

4 + 4 + 4 = 12

---

## (d) Output-Stationary Answer

If the array were output-stationary instead, the C partial sums would stay fixed in the PEs. The A values and B weights would stream through the array while each PE keeps accumulating its own output value.

Weight-stationary keeps weights fixed inside PEs, which reduces memory movement and improves efficiency.
