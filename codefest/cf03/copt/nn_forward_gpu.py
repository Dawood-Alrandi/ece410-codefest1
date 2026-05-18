"""
nn_forward_gpu.py
Neural network forward pass on GPU
ECE 410/510 Codefest 3, HW4AI Spring 2026
Network: Linear(4 to 5) ReLU Linear(5 to 1), batch size 16
"""
import sys
import torch
import torch.nn as nn

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

if not torch.cuda.is_available():
    print("No CUDA GPU found. Needs a CUDA-capable GPU.")
    sys.exit(1)

print("Device:", torch.cuda.get_device_name(0))

model = nn.Sequential(
    nn.Linear(4, 5),
    nn.ReLU(),
    nn.Linear(5, 1)
).to(device)

x = torch.randn(16, 4).to(device)

with torch.no_grad():
    output = model(x)

print("Output shape:", list(output.shape))
print("Output device:", str(output.device))
