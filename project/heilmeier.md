# Heilmeier Questions

## 1. What are you trying to do?
We are building a convolutional neural network (CNN) with manual backpropagation using NumPy. The goal is to understand how deep learning models work at a low level without using frameworks like PyTorch or TensorFlow.

## 2. How is it done today, and what are the limits?
Today, most CNNs are implemented using high-level frameworks like PyTorch or TensorFlow. These tools automate backpropagation and optimization, but they hide the internal computations, making it harder to understand how the model actually works.

## 3. What is new in your approach?
Our approach manually implements every step of the CNN, including forward pass and backward pass. This gives full visibility into convolution, pooling, activation, and gradient calculations.

## 4. Who cares? Why does it matter?
This matters because understanding the internal operations of neural networks helps in designing better models and optimizing performance. It is especially useful for hardware acceleration and research.

## 5. What are the risks?
The main risks are implementation errors and inefficiency compared to optimized frameworks. Manual implementation is also slower and harder to scale.

## 6. How will you measure success?
Success is measured by correctly running the model, producing expected outputs, and generating profiling results that identify computational bottlenecks.

## 7. What are the next steps?
Next steps include optimizing performance, improving accuracy, and exploring hardware acceleration techniques.
