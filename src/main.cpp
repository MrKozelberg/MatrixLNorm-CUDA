#include <cstdlib>
#include <cmath>
#include <ctime>
#include <iostream>
#include <random>

#define A_MIN -5
#define A_MAX 5
#define PRINT false

int main(int argc, char **argv){
  // First point of the time measurement
  clock_t t = clock();
  // Shape of the matrix A (m x n)
  int m = std::atoi(argv[1]);
  int n = std::atoi(argv[2]);
  if (PRINT) std::cout << "m=" << m << ", n=" << n << std::endl;
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
  // Calculation of the each column l-norm
  float *temp;
  temp = (float*)malloc(n*sizeof(float));
  for(int j = 0; j < n; j++){
    temp[j] = 0.;
    for(int i = 0; i < m; i++){
      temp[j] += std::abs(a[i][j]);
    }
    //std::cout << temp[j] << std::endl;
  }
  // Finding the maximum value of the temp array
  float temp_max = 0.;
  for(int j = 0; j < n; j++){
    if(temp_max < temp[j]){
      temp_max = temp[j];
    }
  }
  if (PRINT) std::cout << "result: " << temp_max << std::endl;
  // Last point of the time measurement
  if (PRINT) std::cout << "time [s]: ";
  std::cout << float(clock() - t) / float(CLOCKS_PER_SEC) << std::endl;
  return 0;
}
