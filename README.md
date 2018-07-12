# ubuntu-docker-mpi-hpc
Scripts for setting MPI HPC with docker for linux Ubuntu hosts

Prereq: docker installed, user has docker rights



0) create ssh-key (ssh-keygen) and copy the public part (ssh-copy-id localhost)  into your ~/.ssh/authorized_keys -- ~/.ssh folder is copied inside the containers for paswordless connection with the host

1) chmod +x *.sh

2) To create and launch e.g. 10 containers (Ubuntu 18 based) just run:

./create_hpc.sh 10

-- will create set of 10 docker containers (node1,node2...node10) which can be reached by mpirun from host using pdsh or ssh or mpirun with hostsfile created automatically (see example inside it)


Now you can have fun.


Destruction:

3)
./clean.sh to delete all stopped containers and docker hpc-subnet (uncomment 2nd line inside to delete also running containers)

4)
./tentakel.sh CMD

-- will run CMD across all containers in series

--------------------------
These scripts use my docker repository aa3025/ubuntu-mpi-hpc (1 node of HPC, can manually pull as "docker pull aa3025/ubuntu-mpi-hpc")
