# CMAN: AER Bandwidth Analysis for Spiking Neural Network
ECE 410/510 Codefest 8, HW4AI Spring 2026

System: SNN with N=1024 output neurons, mean firing rate f=50 Hz per neuron.
Each AER packet = 10-bit address + 6-bit timestamp + 4-bit framing = 20 bits total.

## Task 1: Mean Aggregate Spike Rate R

R = N x f
R = 1024 x 50
R = 51,200 spikes/second

## Task 2: Mean AER Bandwidth B

B = R x 20 bits per packet
B = 51,200 x 20
B = 1,024,000 bits/second
B = 1.024 Mbit/s

## Task 3: Interface Comparison

| Interface | Max Bandwidth | Sustains Mean Rate? | Lowest Complexity? |
|-----------|--------------|--------------------|--------------------|
| SPI | up to 50 Mbit/s | Yes (1.024 << 50) | No |
| I2C | up to 3.4 Mbit/s | Yes (1.024 << 3.4) | Yes, chosen |
| AXI4-Lite | 100 Mbit/s effective | Yes | No, too complex |

The mean AER bandwidth is 1.024 Mbit/s. All three interfaces can sustain it.
I2C at 3.4 Mbit/s is the lowest complexity interface that still has enough headroom.
SPI works too but adds chip select complexity. AXI4-Lite is overkill for this bandwidth.

Chosen lowest-complexity interface: I2C (Fast-mode Plus at 1 Mbit/s or High-speed at 3.4 Mbit/s)

## Task 4: Burst Peak Bandwidth and Burst-to-Mean Ratio

Burst: 25% of 1024 neurons fire within a 1 ms window.
Neurons firing in burst = 0.25 x 1024 = 256 neurons
Packets in 1 ms = 256 packets
Bits in 1 ms = 256 x 20 = 5,120 bits
Peak bandwidth = 5,120 bits / 0.001 seconds = 5,120,000 bits/second = 5.12 Mbit/s

Burst-to-mean ratio = 5.12 / 1.024 = 5x

I2C at 3.4 Mbit/s cannot absorb the burst (5.12 > 3.4). Buffering is required.
A FIFO buffer of at least 5.12 / 3.4 x 1 ms worth of data is needed to absorb the burst.
Approximate buffer depth = ceil((5.12 - 3.4) / 3.4 x 1 ms x 3.4 Mbit/s) = about 512 bits = 26 packets deep.

## Task 5: Frame-Based Comparison

Frame-based: all 1024 neurons sampled every 1 ms, 1 bit per neuron.
Frame bandwidth = 1024 bits / 0.001 s = 1,024,000 bits/s = 1.024 Mbit/s

AER-to-frame ratio at f=50 Hz: B_AER / B_frame = 1.024 / 1.024 = 1.0

The bandwidths are equal at f = 50 Hz. Setting them equal and solving for crossover firing rate f_crossover:

AER bandwidth = N x f x 20
Frame bandwidth = N x 1 (1 bit per neuron per ms = N bits per ms = N x 1000 bits/s)

Set equal:
N x f_crossover x 20 = N x 1000
f_crossover x 20 = 1000
f_crossover = 50 Hz

This confirms f=50 Hz is the crossover point. AER is more efficient than frame-based readout when the mean firing rate is below 50 Hz because it only transmits when neurons fire, while frame-based always sends all N bits regardless of activity.
