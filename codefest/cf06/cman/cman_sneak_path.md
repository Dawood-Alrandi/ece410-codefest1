# CMAN — Sneak Paths in a 2×2 Resistive Crossbar
ECE 410/510 Codefest 6 — HW4AI Spring 2026

## Circuit Setup

```
           col 0 (0V)        col 1 (float)
              |                   |
V_row0 ──[R00=1kΩ on]──┬──[R01=2kΩ off]──┐
 (1V)                  ↓                  |
                    I_col0             V_col1
V_row1 ──[R10=2kΩ off]─┘──[R11=1kΩ on]──┘
(float)
```

Cell resistances:
- R[0][0] = 1 kΩ (on — encodes weight "1")
- R[0][1] = 2 kΩ (off — encodes weight "0")
- R[1][0] = 2 kΩ (off — encodes weight "0")
- R[1][1] = 1 kΩ (on — encodes weight "1")

---

## (a) Task 1 — Ideal Read

**Conditions:** V_row0 = 1 V, col 0 = 0 V (virtual ground), row 1 = 0 V (grounded), col 1 = 0 V (grounded)

With all undriven nodes held at 0 V, only R[0][0] has a voltage across it:

```
I_col0_ideal = V_row0 / R[0][0]
             = 1 V / 1 kΩ
             = 1.0 mA
```

- R[1][0] = 2 kΩ: both ends at 0 V → no current
- R[0][1] = 2 kΩ: current flows but exits to grounded col 1, not col 0

**I_col0 (ideal) = 1.0 mA**

---

## (b) Task 2 — Sneak Path Read: KCL Solution

**Conditions:** V_row0 = 1 V, col 0 = 0 V (held), row 1 = floating (V_row1), col 1 = floating (V_col1)

**Unknown nodes:** V_row1, V_col1

### KCL at V_row1 (floating row node)

All currents leaving V_row1 must sum to zero:

```
(V_row1 - V_col1)/R[1][1]  +  (V_row1 - 0)/R[1][0]  =  0

(V_row1 - V_col1)/1 kΩ  +  V_row1/2 kΩ  =  0

Multiply through by 2 kΩ:
  2(V_row1 - V_col1) + V_row1 = 0
  3·V_row1 - 2·V_col1 = 0
  V_row1 = (2/3)·V_col1     ... (Equation 1)
```

### KCL at V_col1 (floating column node)

All currents leaving V_col1 must sum to zero:

```
(V_col1 - 1)/R[0][1]  +  (V_col1 - V_row1)/R[1][1]  =  0

(V_col1 - 1)/2 kΩ  +  (V_col1 - V_row1)/1 kΩ  =  0

Multiply through by 2 kΩ:
  (V_col1 - 1) + 2(V_col1 - V_row1) = 0
  3·V_col1 - 2·V_row1 = 1     ... (Equation 2)
```

### Solving the System

Substitute Equation 1 into Equation 2:

```
3·V_col1 - 2·(2/3)·V_col1 = 1
3·V_col1 - (4/3)·V_col1   = 1
(9/3 - 4/3)·V_col1         = 1
(5/3)·V_col1               = 1

V_col1 = 3/5 = 0.6 V
V_row1 = (2/3) × 0.6 = 0.4 V
```

---

## (c) Task 2 — Actual I_col0 with Sneak Path Itemized

Using solved voltages: V_row0 = 1 V, V_row1 = 0.4 V, V_col0 = 0 V, V_col1 = 0.6 V

| Path | Resistor | Formula | Current |
|------|----------|---------|---------|
| Intended: row0 → col0 | R[0][0] = 1 kΩ | (1 − 0) / 1 kΩ | **1.00 mA** |
| Sneak: row0 → col1 | R[0][1] = 2 kΩ | (1 − 0.6) / 2 kΩ | 0.20 mA |
| Sneak: row1 → col0 ← | R[1][0] = 2 kΩ | (0.4 − 0) / 2 kΩ | **+0.20 mA** ← adds to col0! |
| Sneak: col1 → row1 | R[1][1] = 1 kΩ | (0.4 − 0.6) / 1 kΩ | −0.20 mA |

**KCL verification:**
- At V_row1: −0.20 mA (to col1) + 0.20 mA (to col0) = 0 ✓
- At V_col1: +0.20 mA (from row0) − 0.20 mA (to row1) = 0 ✓

**Actual I_col0 = I_R00 + I_R10 = 1.00 + 0.20 = 1.20 mA**

| | Value |
|---|---|
| Ideal I_col0 | 1.00 mA |
| Sneak contribution (I_R10) | +0.20 mA |
| **Actual I_col0** | **1.20 mA** |
| Error | **+20% higher than ideal** |

---

## (d) How Sneak Paths Corrupt MVM Results

In a resistive crossbar, the intended Matrix-Vector Multiplication (MVM) reads column current as the dot product of the input voltage vector and the weight row of that column. Sneak paths create unintended current routes through floating rows and columns — in this case, current flows from the driven row (row 0) through the off-cell R[0][1] into floating col 1, then through the on-cell R[1][1] into floating row 1, and finally through off-cell R[1][0] into the sensed column (col 0), adding a spurious 0.20 mA that was never encoded in the weight matrix.

This means the sensed current no longer represents the true dot product: col 0 reads 1.20 mA instead of 1.00 mA, a 20% error. In large crossbar arrays this problem scales severely — with N floating rows and columns, each unselected on-state cell can contribute its own sneak path, and the cumulative error grows roughly with array size, making accurate MVM impossible without active mitigation such as selector devices (e.g., transistors or diodes in series with each cell) or virtual ground sensing on all columns simultaneously.
