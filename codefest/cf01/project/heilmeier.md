# Heilmeier Questions

## 1. What are you trying to do?
I am trying to design a hardware accelerator for a convolutional neural network with manual backpropagation training. My focus is the convolution part of the model, especially the Conv2D._im2col kernel because it is the main hotspot in the software version.

## 2. How is it done today, and what are the limits of current practice?
Today, this is done in software on a CPU using Python. The main limit is that the convolution-related work is expensive and takes most of the runtime. The Python implementation also adds overhead because it uses nested loops and repeated memory movement.

## 3. What is new in your approach and why do you think it will be successful?
My approach is to identify the dominant kernel with profiling, measure its arithmetic intensity, place it on a roofline, and then design a hardware accelerator for that kernel. I think this will work because the convolution kernel is compute-heavy and is a better target for acceleration than the rest of the code.
