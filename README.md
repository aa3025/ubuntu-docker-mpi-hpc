# ubuntu-docker-mpi-hpc
scripts for setting mpi hpc with docker for linux hosts

just run ./create_hpc.sh to create set of docker containers which can be reached by mpirun from host
./clean.sh to delete all containers and docker hpc-subnet (careful will delete also running containers, disable --force to delete only stopped ones)
./tentakel CMD  -- will run CMD across all containers in series

These scripts use my docker repository aa3025/ubuntu-mpi-hpc (1 node of HPC, can manually pull as "docker pull aa3025/ubuntu-mpi-hpc")

