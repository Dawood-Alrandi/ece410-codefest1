# CMAN — Manual INT8 Symmetric Quantization

## Given Weight Matrix W (FP32)

```
W = [  0.85,  -1.20,   0.34,   2.10 ]
    [ -0.07,   0.91,  -1.88,   0.12 ]
    [  1.55,   0.03,  -0.44,  -2.31 ]
    [ -0.18,   1.03,   0.77,   0.55 ]
```

---

## (a) Scale Factor S

**Formula:** S = max(|W|) / 127

Scanning all 16 elements:
- max(|W|) = **2.31** (element W[2][3] = -2.31)

```
S = 2.31 / 127 = 0.018189...
```

**S ≈ 0.018189**

---

## (b) INT8 Quantization: W_q = round(W / S), clamped to [−128, 127]

**Formula per element:** W_q[i][j] = clamp(round(W[i][j] / 0.018189), −128, 127)

**Calculations (selected):**
- W[0][0] = 0.85 / 0.018189 = 46.73 → round → **47**
- W[0][1] = -1.20 / 0.018189 = -65.97 → round → **-66**
- W[0][3] = 2.10 / 0.018189 = 115.45 → round → **115**
- W[2][3] = -2.31 / 0.018189 = -127.0 → round → **-127**

**W_q (4×4 INT8 matrix):**

| | Col 0 | Col 1 | Col 2 | Col 3 |
|---|-------|-------|-------|-------|
| **Row 0** | 47 | -66 | 19 | 115 |
| **Row 1** | -4 | 50 | -103 | 7 |
| **Row 2** | 85 | 2 | -24 | -127 |
| **Row 3** | -10 | 57 | 42 | 30 |

No clamping was required (all values within [−128, 127]).

---

## (c) Dequantization: W_deq = W_q × S

**W_deq (4×4 FP32 matrix):**

| | Col 0 | Col 1 | Col 2 | Col 3 |
|---|-------|-------|-------|-------|
| **Row 0** | 0.854882 | -1.200472 | 0.345591 | 2.091732 |
| **Row 1** | -0.072756 | 0.909449 | -1.873465 | 0.127323 |
| **Row 2** | 1.546063 | 0.036378 | -0.436535 | -2.310000 |
| **Row 3** | -0.181890 | 1.036772 | 0.763937 | 0.545669 |

---

## (d) Error Analysis

**Absolute error |W − W_deq|:**

| | Col 0 | Col 1 | Col 2 | Col 3 |
|---|-------|-------|-------|-------|
| **Row 0** | 0.004882 | 0.000472 | 0.005591 | **0.008268** |
| **Row 1** | 0.002756 | 0.000551 | 0.006535 | 0.007323 |
| **Row 2** | 0.003937 | 0.006378 | 0.003465 | 0.000000 |
| **Row 3** | 0.001890 | 0.006772 | 0.006063 | 0.004331 |

**Element with largest error:** W[0][3] = 2.10, dequantized to 2.091732, error = **0.008268**

**Mean Absolute Error (MAE):**
```
MAE = sum of all 16 errors / 16
    = 0.069309 / 16
    = 0.004332
```

**MAE ≈ 0.0043** (consistent with S/2 ≈ 0.0091 as the maximum rounding error)

---

## (e) Bad Scale Experiment: S_bad = 0.01

**Quantizing with S_bad = 0.01 (too small):**

W_q_bad[i][j] = clamp(round(W[i][j] / 0.01), −128, 127)

Selected elements:
- W[0][3] = 2.10 / 0.01 = 210 → clamp → **127** (saturated!)
- W[1][2] = -1.88 / 0.01 = -188 → clamp → **-128** (saturated!)
- W[2][0] = 1.55 / 0.01 = 155 → clamp → **127** (saturated!)
- W[2][3] = -2.31 / 0.01 = -231 → clamp → **-128** (saturated!)

**W_q_bad:**

| | Col 0 | Col 1 | Col 2 | Col 3 |
|---|-------|-------|-------|-------|
| **Row 0** | 85 | -120 | 34 | **127** ← clipped |
| **Row 1** | -7 | 91 | **-128** ← clipped | 12 |
| **Row 2** | **127** ← clipped | 3 | -44 | **-128** ← clipped |
| **Row 3** | -18 | 103 | 77 | 55 |

**W_deq_bad:** 4 elements saturate at ±1.27 instead of their true values.

**MAE with S_bad = 0.01: 0.171250** (compared to 0.004332 with correct S — 40× worse!)

**One-sentence explanation:** When S is too small, weight values larger than S × 127 = 1.27 in magnitude cannot be represented in INT8 and are clamped to ±127, causing large systematic clipping errors that corrupt the model's learned weights and degrade accuracy significantly.
