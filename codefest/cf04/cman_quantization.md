1. Scale Factor

max(|W|) = 2.31

S = max(|W|) / 127
S = 2.31 / 127 ≈ 0.01819


2. Quantized Matrix (W_q)

W_q = round(W / S)

[  47   -66    19   116 ]
[  -4    50  -103     7 ]
[  85     2   -24  -127 ]
[ -10    57    42    30 ]


3. Dequantized Matrix (W_deq)

W_deq = W_q × S

[  0.855  -1.201   0.346   2.109 ]
[ -0.073   0.910  -1.874   0.127 ]
[  1.546   0.036  -0.437  -2.309 ]
[ -0.182   1.036   0.764   0.546 ]


4. Error Analysis

Error = |W − W_deq|

Largest error ≈ 0.009

Mean Absolute Error (MAE) ≈ 0.005


5. Bad Scale Experiment (S = 0.01)

Some values exceed int8 range and get clamped to [-128, 127]

Example:
2.31 / 0.01 = 231 → clamped to 127

This causes large error

MAE becomes much larger (around 0.2 range)

Final Answer
When S is too small, values get clipped to the int8 limits, which causes large errors and loss of information.
