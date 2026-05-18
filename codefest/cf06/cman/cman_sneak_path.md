# CMAN: Sneak Paths in a 2x2 Resistive Crossbar
ECE 410/510 Codefest 6, HW4AI Spring 2026

Cell resistances: R[0][0]=1k on, R[0][1]=2k off, R[1][0]=2k off, R[1][1]=1k on.
Encoding: 1k = weight on, 2k = weight off.

## (a) Ideal Read

Conditions: V_row0=1V, col0=0V (virtual ground), row1=0V grounded, col1=0V grounded.

Only R[0][0] has voltage across it:

I_col0_ideal = V_row0 / R[0][0] = 1V / 1k = 1.0 mA

R[1][0] has 0V across it (both ends grounded) so no current flows.
R[0][1] current goes to grounded col1, not to col0.

I_col0 ideal = 1.0 mA

## (b) Sneak Path Read: KCL Solution

Conditions: V_row0=1V, col0=0V held, row1=floating (V_row1), col1=floating (V_col1).

Unknown nodes: V_row1 and V_col1.

KCL at V_row1 (sum of currents leaving = 0):

(V_row1 - V_col1) / R[1][1] + V_row1 / R[1][0] = 0
(V_row1 - V_col1) / 1k + V_row1 / 2k = 0

Multiply by 2k:
2(V_row1 - V_col1) + V_row1 = 0
3 V_row1 = 2 V_col1
V_row1 = (2/3) V_col1   ...(Equation 1)

KCL at V_col1 (sum of currents leaving = 0):

(V_col1 - 1) / R[0][1] + (V_col1 - V_row1) / R[1][1] = 0
(V_col1 - 1) / 2k + (V_col1 - V_row1) / 1k = 0

Multiply by 2k:
(V_col1 - 1) + 2(V_col1 - V_row1) = 0
3 V_col1 - 2 V_row1 = 1   ...(Equation 2)

Substitute Equation 1 into Equation 2:
3 V_col1 - 2 x (2/3) V_col1 = 1
(9/3 - 4/3) V_col1 = 1
(5/3) V_col1 = 1
V_col1 = 0.6V

V_row1 = (2/3) x 0.6 = 0.4V

## (c) Actual I_col0 with Sneak Path

Using V_row0=1V, V_row1=0.4V, V_col0=0V, V_col1=0.6V:

| Path | Resistor | Calculation | Current |
|------|----------|-------------|---------|
| Intended: row0 to col0 | R[0][0]=1k | (1-0)/1k | 1.00 mA |
| Sneak entry: row0 to col1 | R[0][1]=2k | (1-0.6)/2k | 0.20 mA |
| Sneak into col0: row1 to col0 | R[1][0]=2k | (0.4-0)/2k | +0.20 mA |
| Sneak return: col1 to row1 | R[1][1]=1k | (0.4-0.6)/1k | -0.20 mA |

KCL check at V_row1: +0.20 from col1 - 0.20 to col0 = 0. Correct.
KCL check at V_col1: +0.20 from row0 - 0.20 to row1 = 0. Correct.

Actual I_col0 = 1.00 + 0.20 = 1.20 mA

| | Value |
|---|---|
| Ideal I_col0 | 1.00 mA |
| Sneak contribution | +0.20 mA |
| Actual I_col0 | 1.20 mA |
| Error | +20% higher than ideal |

## (d) How Sneak Paths Corrupt MVM Results

The crossbar is supposed to compute a dot product by reading column current as the weighted sum of input voltages. Sneak paths create extra current routes through floating rows and columns that were not selected. In this case current flows from row0 through the off-cell R[0][1] into floating col1, then through the on-cell R[1][1] into floating row1, and finally through the off-cell R[1][0] into the sensed column. This adds 0.20 mA that does not belong in the result. The measured current is 1.20 mA instead of the correct 1.00 mA, a 20% error. In larger arrays this problem gets worse because more unselected on-state cells can each contribute their own sneak path. This makes accurate MVM impossible in large crossbars without selector devices or sensing all columns simultaneously.
