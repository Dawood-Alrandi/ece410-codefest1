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

### KCL at V_row1

```
(V_row1 - V_col1)/1k + V_row1/2k = 0
3*V_row1 = 2*V_col1  -->  V_row1 = (2/3)*V_col1   (Eq 1)
```

### KCL at V_col1

```
(V_col1 - 1)/2k + (V_col1 - V_row1)/1k = 0
3*V_col1 - 2*V_row1 = 1                    (Eq 2)
```

### Solution

Substitute Eq 1 into Eq 2:
```
3*V_col1 - 2*(2/3)*V_col1 = 1
(5/3)*V_col1 = 1
V_col1 = 0.6 V
V_row1 = (2/3)*0.6 = 0.4 V
```

---

## (c) Actual I_col0 with Sneak Path Itemized

Using solved voltages: V_row0=1V, V_row1=0.4V, V_col0=0V, V_col1=0.6V

| Path | Resistor | Formula | Current |
|------|----------|---------|---------|
| Intended: row0 → col0 | R[0][0]=1k | (1-0)/1k | **1.00 mA** |
| Sneak: row0 → col1 | R[0][1]=2k | (1-0.6)/2k | 0.20 mA |
| Sneak: row1 → col0 | R[1][0]=2k | (0.4-0)/2k | **+0.20 mA** (adds to col0!) |
| Sneak: col1 → row1 | R[1][1]=1k | (0.4-0.6)/1k | -0.20 mA |

**KCL check: at V_row1: -0.20 + 0.20 = 0 ✑, at V_col1: +0.20 - 0.20 = 0 ✐**

| | Value |
|---|---|
| Ideal I_col0 | 1.00 mA |
| Sneak contribution | +0.20 mA |
| **Actual I_col0** | **1.20 mA** |
| Error | **+20% higher** |

---

## (d) How Sneak Paths Corrupt MVM

Sneak paths create unintended current routes through floating rows and columns: current flows from row0 through off-cell R[0][1], through on-cell R[1][1], and out through off-cell R[1][0] into the sensed column, adding a spurious 0.20 mA never encoded in the weight matrix. The sensed current no longer represents the true dot product (20% error), and in large arrays this error grows with array size, making accurate MVM impossible without selector devices or virtual-ground sensing on all columns simultaneously.