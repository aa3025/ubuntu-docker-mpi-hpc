#!/bin/bash


# remove all stopped containers
docker rm $(docker ps -a -q)

# brutal: (will remove also running ones)
docker rm --force $(docker ps -a -q)

# remove network for hpc
docker network rm hpcnet
rm -fr nodes hosts machines
