#!/bin/bash

#number of nodes to create
N=10
dockernet="172.18.0"

echo "" > ./hosts
echo "" > ./nodes
for i in $(seq 1 $N)
do
	nodenr=$((100 + $i))
	echo $dockernet.$nodenr node$i >> hosts
	echo $dockernet.$nodenr >> ./nodes
done
hpcnet=""
#uncomment to create new subnet
docker network create --subnet=$dockernet.0/16 hpcnet

# docker subnet to use:
hpcnet="--net hpcnet"
###############################


for i in $(seq 1 $N)
do
echo creating node$i
	nodenr=$((100 + $i))
	IP=$dockernet.$nodenr
	docker run -ti -d -v ~/.ssh:/root/.ssh $hpcnet --ip $IP --name node$i --hostname node$i aa3025/ubuntu-mpi-hpc bash
	sleep 2
	docker cp ./hosts node$i:/hosts
	docker exec node$i bash -c "cat /hosts >> /etc/hosts"

	docker exec node$i bash -c "service ssh start"
done


export PDSH_RCMD_TYPE='ssh'

echo "Host $dockernet.*" >> ~/.ssh/config
echo "   StrictHostKeyChecking no" >> ~/.ssh/config

pdsh -w ^nodes hostname

#apt install openmpi-bin -y

mpirun -n $N -hostfile nodes hostname
