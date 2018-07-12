# ubuntu-docker-mpi-hpc
scripts for setting mpi hpc with docker for linux hosts


1) To create and launch e.g. 10 containers (Ubuntu 18 based) just run:

./create_hpc.sh 10
will create set of 10 docker containers (node1,node2...node10) which can be reached by mpirun from host using pdsh or ssh

2) ./clean.sh to delete all stopped containers and docker hpc-subnet (uncomment 2nd line inside to delete also running containers) 

3) ./tentakel CMD  -- will run CMD across all containers in series

These scripts use my docker repository aa3025/ubuntu-mpi-hpc (1 node of HPC, can manually pull as "docker pull aa3025/ubuntu-mpi-hpc")

