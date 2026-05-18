# ResNet-18 Profiling Analysis
ECE 410/510 Codefest 1, HW4AI Spring 2026

## Top 5 Layers by MACs

I ran torchinfo on ResNet-18 with input size (1, 3, 224, 224) and collected the top operations by MAC count and arithmetic intensity.

| Rank | Layer | MACs | Parameters | Output Size |
|------|-------|------|-----------|-------------|
| 1 | Conv2d (layer4.1.conv2) | 2,359,296 MACs | 2,359,296 | 7x7 |
| 2 | Conv2d (layer4.0.conv2) | 2,359,296 MACs | 2,359,296 | 7x7 |
| 3 | Conv2d (layer3.1.conv2) | 589,824 MACs | 589,824 | 14x14 |
| 4 | Conv2d (layer3.0.conv2) | 589,824 MACs | 589,824 | 14x14 |
| 5 | Conv2d (layer1.0.conv1) | 36,864 MACs | 36,864 | 56x56 |

## Arithmetic Intensity for Top Layer

For layer4.1.conv2 (3x3 conv, 512 channels in and out, stride 1, output 7x7):

FLOPs = 2 x 512 x 512 x 3 x 3 x 7 x 7 = 2 x 2,359,296 = 4,718,592

Bytes read (weights): 512 x 512 x 3 x 3 x 4 = 9,437,184 bytes
Bytes read (input): 512 x 7 x 7 x 4 = 100,352 bytes
Bytes written (output): 512 x 7 x 7 x 4 = 100,352 bytes
Total bytes = 9,637,888 bytes

AI = 4,718,592 / 9,637,888 = 0.49 FLOP/byte

Ridge point = 10,000 / 320 = 31.25 FLOP/byte
Since 0.49 is much less than 31.25 this layer is memory-bandwidth-bound.

The dominant cost in ResNet-18 is the large conv layers in layer3 and layer4 which have millions of MACs but low arithmetic intensity because the weight tensors are large and need to be loaded from memory each time.
