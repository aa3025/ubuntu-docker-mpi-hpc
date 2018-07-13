#!/bin/bash

#number of nodes to create
N=$1
# create different subnet for docker (normally main subnet is 172.17.0.0/24), this will be dedicated to HPC
dockernet="172.18.0"

echo "" > ./hosts
echo "" > ./nodes
if [[ "$N" -eq 0 ]]; then
    N=0
fi

for i in $(seq 0 $N)
do
    nodenr=$((100 + $i))
    if [[ "$i" -eq 0 ]]; then
	echo $dockernet.$nodenr master >> hosts
    else
	echo $dockernet.$nodenr node$i >> hosts
	echo $dockernet.$nodenr >> ./nodes
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
	docker run -ti -d -v ~/.ssh:/root/.ssh $hpcnet --ip $IP --name master --hostname master aa3025/ubuntu-mpi-hpc bash
	sleep 2
	docker cp ./hosts master:/hosts
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
# Procs=1:4(hw) Boards=1:1(hw) SocketsPerBoard=1:1(hw) CoresPerSocket=1:2(hw) ThreadsPerCore=1:2(hw)

echo NodeName=node$i $nodeconfig >> ./slurm.conf

	docker run -ti -d -v ~/.ssh:/root/.ssh $hpcnet --ip $IP --name node$i --hostname node$i aa3025/ubuntu-mpi-hpc bash
	sleep 2
	docker cp ./hosts node$i:/hosts
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

#docker exec master bash -c "echo export PDSH_RCMD_TYPE='ssh'>> /etc/bash.bashrc"
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

pdsh -w ^nodes hostname
docker exec master bash -c "pdsh hostname"

#apt install openmpi-bin -y

mpirun --allow-run-as-root -n $N -hostfile nodes hostname
