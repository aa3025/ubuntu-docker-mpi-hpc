#!/bin/bash
#run across the nodes

#nr of nodes
N=10
for i in $(seq 1 $N)
do
docker exec  -t node$i  bash -c "$1"
done

docker exec  -t master  bash -c "$1"