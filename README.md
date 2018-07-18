# ubuntu-docker-mpi-hpc
Scripts for setting MPI SLURM HPC with docker for linux Ubuntu hosts

Prereq: docker.io package installed, user has docker rights or sudo priv's.


====================== Creation of HPC ==============================


Prerequisites:

0) apt install docker.io

1) add your user to docker group (or run it all as a root):  sudo usermod -aG docker $USER

2) chmod +x *.sh (if needed, normally GitHub preserves permissions)

3) if necessary edit the file nodeconfig.txt which describes number of CPUs on each compute node. Could match your computer CPU specs.This will be the specs of docker compute nodes to be put into SLURM's slurm.conf. Sometimes, if they do not match your real HW slurmd may fail to start in nodes' containers (but can as well work with provided defaults, 4 CPUs per node). 

4) Now we are ready to deploy HPC: for master node + 10 compute nodes, run:

./create_hpc.sh 10

-- this will create master container "master" running SLURM controller (slurmctld) and set of 10 compute-nodes containers (node1,node2...node10) which can be reached from master using pdsh or ssh or mpirun with hostsfile (/etc/machines) created automatically. On each node slurmd and munge services are started. pdsh is configured on master with /etc/machines list of nodes.

./create_hpc.sh (without parameters)
Will only create master container (useful for making changes to base container and saving it to docker image, can use it as a template for nodes)
The only difference between master and nodes' containers is that slurmctld is started on master and slurmd on nodes. Base image is the same  Ubuntu 18 + settings mods. All differences between master and nodes are implemented by "create_hpc.sh" during the launch of the containers.

Once deployed, you are automatically brought to master node's shell (Ctrl+D to exit it) or you can ssh to master ("ssh root@172.19.0.100" with ssh keys in ./.ssh and rule your HPC (e.g. try "srun -n10 hostname" as a 1st step)

====================== Destruction of HPC ==============================

5) auxiliary script ./clean.sh 

-- will delete all containers (running or not) and temp config files as well as docker hpc-subnet "hpcnet" (uncomment 2nd line inside to delete also running containers). You can edit it to delete also docker images or to delete only stopped containers.

6) auxiliary script
./tentakel.sh CMD

-- will run CMD across all containers in series (change value of N inside to number of nodes)

7) optional script 

./hpc.sh start|stop N  

 -- start/stop existing N containers (nodes[1-N] and master)

--------------------------


These scripts use my docker repository aa3025/ubuntu-docker-mpi-hpc (1 node of HPC, can manually pull as "docker pull aa3025/ubuntu-docker-mpi-hpc")
https://hub.docker.com/r/aa3025/ubuntu-docker-mpi-hpc/

