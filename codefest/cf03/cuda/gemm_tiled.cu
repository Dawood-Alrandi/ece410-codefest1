#include <stdio.h>
#include <cuda_runtime.h>

#define N 1024
#define TILE 8

__global__ void gemm_tiled(float *A, float *B, float *C) {
    __shared__ float A_tile[TILE][TILE];
    __shared__ float B_tile[TILE][TILE];

    int row = blockIdx.y * TILE + threadIdx.y;
    int col = blockIdx.x * TILE + threadIdx.x;

    float sum = 0.0f;

    for (int t = 0; t < N / TILE; t++) {
        A_tile[threadIdx.y][threadIdx.x] = A[row * N + t * TILE + threadIdx.x];
        B_tile[threadIdx.y][threadIdx.x] = B[(t * TILE + threadIdx.y) * N + col];

        __syncthreads();

        for (int k = 0; k < TILE; k++) {
            sum += A_tile[threadIdx.y][k] * B_tile[k][threadIdx.x];
        }

        __syncthreads();
    }

    C[row * N + col] = sum;
}

int main() {
    float *A, *B, *C;
    float *d_A, *d_B, *d_C;

    size_t size = N * N * sizeof(float);

    A = (float*)malloc(size);
    B = (float*)malloc(size);
    C = (float*)malloc(size);

    for (int i = 0; i < N * N; i++) {
        A[i] = 1.0f;
        B[i] = 1.0f;
    }

    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_C, size);

    cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(TILE, TILE);
    dim3 numBlocks(N / TILE, N / TILE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    gemm_tiled<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    printf("Time: %f ms\n", milliseconds);

    cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    free(A);
    free(B);
    free(C);

    return 0;
}
