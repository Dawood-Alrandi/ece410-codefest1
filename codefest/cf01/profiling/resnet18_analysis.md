# ResNet-18 Analysis

## Top 5 MAC-Intensive Layers

The following table lists the five layers with the highest MAC count from the torchinfo profile of ResNet-18 (batch=1, input 3×224×224, FP32).

| Layer Name    | Output Shape       | MACs            | Parameters |
|---------------|--------------------|-----------------|------------|
| Conv2d 3-42   | [1, 512, 7, 7]     | 115,605,504     | 2,359,296  |
| Conv2d 3-46   | [1, 512, 7, 7]     | 115,605,504     | 2,359,296  |
| Conv2d 3-49   | [1, 512, 7, 7]     | 115,605,504     | 2,359,296  |
| Conv2d 3-39   | [1, 512, 7, 7]     | 57,802,752      | 1,179,648  |
| Conv2d 3-29   | [1, 256, 14, 14]   | 28,901,376      | 589,824    |

> MACs computed as: output_H × output_W × C_out × (C_in × kernel_H × kernel_W)

---

## Arithmetic Intensity of the Most MAC-Intensive Layer

**Layer:** Conv2d 3-42 — 512 input channels, 512 output channels, 3×3 kernel, output 7×7

### MACs
MACs = output_H × output_W × C_out × (C_in × k × k)  
= 7 × 7 × 512 × (512 × 3 × 3)  
= 49 × 512 × 4,608  
= **115,605,504 MACs**

### FLOPs
FLOPs = 2 × MACs = 2 × 115,605,504 = **231,211,008 FLOPs**

### Weight Memory (loaded from DRAM, no reuse)
Weights = C_out × C_in × k × k × 4 bytes  
= 512 × 512 × 3 × 3 × 4  
= **9,437,184 bytes**

### Activation Memory (input + output)
Input activation  = C_in × H_in × W_in × 4 = 512 × 9 × 9 × 4 = 165,888 bytes (padded input)  
Output activation = C_out × H_out × W_out × 4 = 512 × 7 × 7 × 4 = 100,352 bytes  
Total activations = 165,888 + 100,352 = **266,240 bytes**

### Arithmetic Intensity
AI = FLOPs / (weight bytes + activation bytes)  
= 231,211,008 / (9,437,184 + 266,240)  
= 231,211,008 / 9,703,424  
≈ **23.8 FLOP/byte**

This layer has relatively high arithmetic intensity (~24 FLOP/byte), meaning it is near or above the ridge point of many GPUs and is well-suited for hardware acceleration.
