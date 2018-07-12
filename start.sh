#!/bin/bash

# optional if containers are stopped but exist

for i in $(seq 0 10)
do
docker start node$i 
done
