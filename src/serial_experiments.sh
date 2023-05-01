#!/bin/bash
cppcode=main.cpp
cppout=main_cpp.out
g++ $cppcode -o $cppout
df=../data/serial_experiments.csv
echo "experiment,m,n,time [s]" > $df
ms=(10 50 100 500 1000 5000 10000 50000 100000)
ns=(10 50 100 500 1000 5000 10000)
experiments=(1 2 3)
for experiment in ${experiments[@]}
do
  for m in ${ms[@]}
  do
    for n in ${ns[@]}
    do
      ./$cppout $m $n > t
      read t < "t"
      echo "$experiment,$m,$n,$t" >> $df
      echo "$experiment,$m,$n,$t"
    done
  done
done
# cleaning
rm *.out
rm t
