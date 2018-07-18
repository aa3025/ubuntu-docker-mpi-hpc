#!/bin/bash

#number of nodes to create
N=$1
# create different subnet for docker (normally main subnet is 172.17.0.0/24), this will be dedicated to HPC
dockernet="172.19.0"

# shared folder for HPC's nodes (e.g. for slurm jobs)
mkdir -p ./share
mkdir -p ./temp

echo "" > ./temp/hosts
echo "" > ./temp/nodes
if [[ "$N" -eq 0 ]]; then
    N=0
fi

for i in $(seq 0 $N)
do
    nodenr=$((100 + $i))
    if [[ "$i" -eq 0 ]]; then
	echo $dockernet.$nodenr master >> ./temp/hosts
    else
	echo $dockernet.$nodenr node$i >> ./temp/hosts
	echo $dockernet.$nodenr >> ./temp/nodes
    fi
done


hpcnet=""
#uncomment to create new subnet
docker network create --subnet=$dockernet.0/16 hpcnet

# docker subnet to use:
hpcnet="--net hpcnet"
###############################

## master node

echo creating master
	nodenr=100
	IP=$dockernet.$nodenr
	docker run -ti -d -v ~/.ssh:/root/.ssh \
			    -v share:/share $hpcnet --ip $IP --name master --hostname master aa3025/ubuntu-docker-mpi-hpc bash
	sleep 2
	docker cp ./temp/hosts master:/hosts
	docker exec master bash -c "cat /hosts >> /etc/hosts"

	docker exec master bash -c "service ssh start"

if [[ "$N" -eq 0 ]]; then
    echo You did not specify number of nodes N to create, usage ./create_hpc.sh N
    exit 0
fi

rm -fr ./slurm.conf
cp -f ./slurm.conf.org ./slurm.conf

nodeconfig=$(cat nodeconfig.txt)
echo "" > machines
for i in $(seq 1 $N)
do
echo creating node$i
	nodenr=$((100 + $i))
	IP=$dockernet.$nodenr

echo NodeName=node$i $nodeconfig >> ./slurm.conf

	docker run -ti -d -v ~/.ssh:/root/.ssh \
			  -v share:/share $hpcnet --ip $IP --name node$i --hostname node$i aa3025/ubuntu-docker-mpi-hpc bash
	sleep 2
	docker cp ./temp/hosts node$i:/hosts
	echo node$i >> machines
	docker exec node$i bash -c "cat /hosts >> /etc/hosts"
	docker exec node$i bash -c "service ssh start"
done

# Partitions
echo PartitionName=all Nodes=node[1-$N] Default=YES MaxTime=24:00:00 State=UP >> ./slurm.conf

docker cp ./machines master:/etc/machines
docker cp ./slurm.conf master:/etc/slurm-llnl/slurm.conf
docker exec master bash -c "service munge start"
docker exec master bash -c "service slurmctld start"

#docker exec master bash -c "echo export PDSH_RCMD_TYPE='ssh'>> /etc/bash.bashrc"  (this was added to image)
#docker exec master bash -c "echo export WCOLL=/etc/machines >> /etc/bash.bashrc"

for i in $(seq 1 $N)
do
    docker cp ./slurm.conf node$i:/etc/slurm-llnl/slurm.conf
    docker exec node$i bash -c "service munge start"
    docker exec node$i bash -c "service slurmd start"
done

export PDSH_RCMD_TYPE='ssh'

echo "Host $dockernet.*" >> ~/.ssh/config
echo "   StrictHostKeyChecking no" >> ~/.ssh/config
chmod 600 ~/.ssh/config

#given pdsh is installed locally we can talk to the nodes
pdsh -w ^nodes hostname



# or the same via the master node
docker exec master bash -c "pdsh hostname"
# you can install stuff on your HPC nodes with e.g.
# docker exec master bash -c "pdsh yum install octave -y"

# apt install openmpi-bin -y
# mpirun --allow-run-as-root -n $N -hostfile nodes hostname
