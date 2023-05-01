#include <cstdlib>
#include <cmath>
#include <ctime>
#include <iostream>
#include <random>
#include "cublas_v2.h"

#define A_MIN -5
#define A_MAX 5
#define PRINT false

__global__ void increseInV2byAbsV1Kernel(int n, float *V2, float *V1){
  // Linear index of the current thread
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  // Adding absolute values of all elements that lie on this thread
  while (idx < n) {
    V2[idx] += std::abs(V1[idx]);
    idx += blockDim.x * gridDim.x;
  }
}

float matrixLNormCUDA(const int m, const int n, float **a, const int blockSize){
  // Number of thread blocks in grid
  int gridSize = (int)ceil((float)n/blockSize);
  // Previous result ?
  float *hostV1, *hostV2;
  hostV1 = (float*)malloc(n*sizeof(float));
  hostV2 = (float*)malloc(n*sizeof(float));
  for(int j = 0; j < n; j++){
    hostV2[j] = 0.;
  }
  // Declaration of the device arrrays
  float *deviceV1, *deviceV2;
  cudaMalloc(&deviceV1, n*sizeof(float));
  cudaMalloc(&deviceV2, n*sizeof(float));
  // Copy host vectors to device
  cudaMemcpy(deviceV2, hostV2, n*sizeof(float), cudaMemcpyHostToDevice);
  // Loop over the all rows of the matrix A
  for(int i = 0; i < m; i++){
    // Filling hostV1 array with values of the current row of the matrix A
    for(int j = 0; j < n; j++){
      hostV1[j] = a[i][j];
    }
    // Copy hostV1 to deviceV1
    cudaMemcpy(deviceV1, hostV1, n*sizeof(float), cudaMemcpyHostToDevice);
    // Add absolute values of the current row to the deviceV2 array
    increseInV2byAbsV1Kernel<<<gridSize, blockSize>>>(n, deviceV2, deviceV1);
  }
  // Copy deviceV2 to host
  cudaMemcpy(hostV2, deviceV2, n*sizeof(float), cudaMemcpyDeviceToHost);
  // Finding maximum element of the deviceV2 array with the help of the CUBLAS
  cublasHandle_t handle;
  cublasStatus_t stat;
  cublasCreate(&handle);
  int max_idx;
  stat = cublasIsamax(handle, n, deviceV2, 1, &max_idx);
  if (stat != CUBLAS_STATUS_SUCCESS)
    std::cout << "Max failed" << std::endl;
  cublasDestroy(handle);
  // Result (CUBLAS indexates elements from 1)
  float result = hostV2[max_idx-1];
  // Release memory
  free(hostV2);
  cudaFree(deviceV1);
  cudaFree(deviceV2);
  // Return result
  return result;
}

int main(int argc, char **argv){
  // First point of the time measurement
  clock_t t = clock();
  // Shape of the matrix A (m x n)
  int m = std::atoi(argv[1]);
  int n = std::atoi(argv[2]);
  int blockSize = std::atoi(argv[3]);
  if (PRINT) std::cout << "m=" << m << ", n=" << n << ", blockSize=" << blockSize << std::endl;
  float **a; // Matrix A declaration
  a = new float *[m];
  for(int i = 0; i < m; i++)
    a[i] = new float[n];
  // Filling this matrix with random values  
  std::random_device rd;  // Will be used to obtain a seed for the random number engine
  std::mt19937 gen(rd()); // Standard mersenne_twister_engine seeded with rd()
  std::uniform_real_distribution<float> dis(A_MIN, A_MAX);
  if (PRINT) std::cout << "matrix A:" << std::endl;
  for(int i = 0; i < m; i++){
    for(int j = 0; j < n; j++){
      a[i][j] = int(dis(gen));
      if (PRINT) std::cout << a[i][j] << " ";
    }
    if (PRINT) std::cout << std::endl;
  }
  float temp_max = matrixLNormCUDA(m,n,a,blockSize);
  if (PRINT) std::cout << "result: " << temp_max << std::endl;
  // Last point of the time measurement
  if (PRINT) std::cout << "time [s]: ";
  std::cout << float(clock() - t) / float(CLOCKS_PER_SEC) << std::endl;
  return 0;
}
