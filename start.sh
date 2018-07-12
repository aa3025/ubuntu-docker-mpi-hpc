#!/bin/bash

# optional if containers are stopped but exist
N=$1
for i in $(seq 0 $N)
do
docker start node$i 
done
