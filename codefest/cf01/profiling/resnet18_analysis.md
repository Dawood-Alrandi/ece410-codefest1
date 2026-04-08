# ResNet-18 Analysis

## Top 5 MAC-Intensive Layers

| Layer Name | Output Shape | Params |
|---|---:|---:|
| Conv2d: 3-42 | [1, 512, 7, 7] | 2,359,296 |
| Conv2d: 3-46 | [1, 512, 7, 7] | 2,359,296 |
| Conv2d: 3-49 | [1, 512, 7, 7] | 2,359,296 |
| Conv2d: 3-39 | [1, 512, 7, 7] | 1,179,648 |
| Conv2d: 3-29 | [1, 256, 14, 14] | 589,824 |

## Arithmetic Intensity

Layer: Conv2d (3-42)

MACs = 7 × 7 × 512 × (512 × 3 × 3)  
= 115,605,504

FLOPs = 2 × MACs  
= 231,211,008

Weights = 512 × 512 × 3 × 3 × 4  
= 9,437,184 bytes

Activations:  
Input = 512 × 7 × 7 × 4 = 100,352 bytes  
Output = 512 × 7 × 7 × 4 = 100,352 bytes

Total activation = 200,704 bytes

AI = FLOPs / (weights + activations)  
= 231,211,008 / 9,637,888  
≈ 24 FLOP/byte

## Conclusion

The most MAC-intensive layers in ResNet-18 are the deeper convolution layers, especially the 512-channel 3×3 convolution layers. These layers dominate the workload because they combine large channel counts with repeated spatial convolution. Their arithmetic intensity is also relatively high, which means they are strong candidates for hardware acceleration.
