#!/bin/bash
cppcode=main.cpp
cudacode=main.cu
cppout=main_cpp.out
cudaout=main_cuda.out
m=3
n=4
blockSize=512
# compilation
g++ $cppcode -o $cppout
nvcc $cudacode -o $cudaout -lcublas
# run programs
echo "Serial code"
./$cppout $m $n
echo ""
echo "CUDA code"
./$cudaout $m $n $blockSize
# cleaning
rm *.out

