# ubuntu-docker-mpi-hpc
Scripts for setting MPI SLURM HPC with docker for linux Ubuntu hosts

Prereq: docker.io package installed, user has docker rights or sudo priv's.

========================================================================

Creation of HPC

1) add your user to docker group (or run it all as a root):  sudo usermod -aG docker $USER

2) create ssh-key (ssh-keygen) and copy the public part (ssh-copy-id localhost)  into your ~/.ssh/authorized_keys. The content of ~/.ssh folder is shared to the containers for paswordless connection with the host and between the containers (master and nodes).

3) chmod +x *.sh (if needed, normally GitHub preserves permissions)

4) if necessary edit file nodeconfig.txt to match your computer CPU specs = this will be nodes specs for SLURM slurm.conf. If they do not match real hardware slurmd may fail to start in nodes' containers.

5) To create and launch master node (a.k.a headnode) and, say, 10 compute-nodes (Ubuntu 18 based) just run:

./create_hpc.sh 10

-- will create master container running Slurm controller (slurmctld) and set of 10 docker containers (node1,node2...node10) which can be reached by mpirun from host or master using pdsh or ssh or mpirun with hostsfile created automatically (see example inside it). On each node slurmd and munge demons are started. pdsh is configured on master.

./create_hpc.sh (without parameters)
Will only create master container (useful for making changes to base container and saving to docker image to use as a template for nodes)
The only difference between master and nodes' containers is that slurmctld is started on master and slurmd on nodes. Base image is identical. All changes between master and nodes are implemented during the launch of the containers.

Once deployed, you can ssh to master ("ssh 172.19.0.100" and rule your HPC (e.g. try "pdsh hostname")

=============================================================================

Destruction of the cluster:

6) auxiliary script ./clean.sh 

-- will delete all stopped containers and temp config files as well as docker hpc-subnet (uncomment 2nd line inside to delete also running containers)

7) auxiliary script
./tentakel.sh CMD

-- will run CMD across all containers in series


8) optional script ./hpc.sh start|stop N  

 -- start/stop existing N containers (nodes[1-N] and master)

--------------------------


These scripts use my docker repository aa3025/ubuntu-docker-mpi-hpc (1 node of HPC, can manually pull as "docker pull aa3025/ubuntu-docker-mpi-hpc")
https://hub.docker.com/r/aa3025/ubuntu-docker-mpi-hpc/
