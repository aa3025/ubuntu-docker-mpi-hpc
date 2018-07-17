#!/bin/bash

# optional if containers exist, can start/stop HPC

#Run as  e.g. "./hpc.sh stop 10" or "./hpc.sh start 10", where 10 is your number of nodes (excluding master)

N=$2
for i in $(seq 1 $N)
do
docker $1 node$i 
done

docker $1 master
