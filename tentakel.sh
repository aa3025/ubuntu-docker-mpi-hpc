#!/bin/bash
#run across the nodes

#nr of nodes
N=10
for i in $(seq 1 $N)
do
docker exec -it node$i  "$1"
done
