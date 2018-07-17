# ubuntu-docker-mpi-hpc
Scripts for setting MPI SLURM HPC with docker for linux Ubuntu hosts

Prereq: docker installed, user has docker rights

========================================================================

Creation of HPC

0) create ssh-key (ssh-keygen) and copy the public part (ssh-copy-id localhost)  into your ~/.ssh/authorized_keys -- ~/.ssh folder is copied inside the containers for paswordless connection with the host

1) chmod +x *.sh

2) if necessary edit file nodeconfig.txt to match your computer CPU specs = this will be nodes specs for SLURM slurm.conf. If they do not match real hardware slurmd may fail to start in nodes' containers.

3) To create and launch master node (a.k.a headnode) and, say, 10 compute-nodes (Ubuntu 18 based) just run:

./create_hpc.sh 10

-- will create master container running Slurm controller (slurmctld) and set of 10 docker containers (node1,node2...node10) which can be reached by mpirun from host or master using pdsh or ssh or mpirun with hostsfile created automatically (see example inside it). On each node slurmd and munge demons are started. pdsh is configured on master.

./create_hpc.sh (without parameters)
Will only create master container (useful for making changes to base container and saving to docker image to use as a template for nodes)
The only difference between master and nodes' containers is that slurmctld is started on master and slurmd on nodes. Base image is identical. All changes between master and nodes are implemented during the launch of the containers.

Once deployed, you can ssh to master ("ssh 172.18.0.100" and rule your HPC (e.g. try "pdsh hostname")

=============================================================================

Destruction of the cluster:

4) auxiliary script ./clean.sh 

-- will delete all stopped containers and temp config files as well as docker hpc-subnet (uncomment 2nd line inside to delete also running containers)

5) auxiliary script
./tentakel.sh CMD

-- will run CMD across all containers in series


6) optional script ./hpc.sh start|stop N  

 -- start/stop existing N containers (nodes[1-N] and master)

--------------------------


These scripts use my docker repository aa3025/ubuntu-docker-mpi-hpc (1 node of HPC, can manually pull as "docker pull aa3025/ubuntu-docker-mpi-hpc")
https://hub.docker.com/r/aa3025/ubuntu-docker-mpi-hpc/
