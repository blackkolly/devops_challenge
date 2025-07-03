What is Docker CLI?
Docker CLI is a command-line tool that allows you to interact with Docker to build, run, and manage containers.


Installation
Docker Installation on Linux (Ubuntu)
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker && sudo systemctl enable docker
sudo usermod -aG docker $USER && newgrp docker
docker --version
Docker Installation on Mac (with Homebrew)
brew install --cask docker
open /Applications/Docker.app
# Wait for Docker to start, then verify
docker --version
Docker Desktop for Mac

Docker Installation on Windows (via PowerShell as Admin)

Download Docker Desktop from here

Or use winget (Windows Package Manager)

winget install --id Docker.DockerDesktop -e
# After installation, start Docker Desktop and verify
docker --version
Running Image
Run a container in detached mode with a name

docker run -d --name <container-name> <image-name>
Run a container in interactive mode with terminal access

docker run -it <image-name> /bin/bash
Run a container with port mapping (host:container)

docker run -d -p 8080:80 <image-name>
Run a container with volume mounting

docker run -v /host/path:/container/path <image-name>
Run a container with environment variables

docker run -e ENV_VAR_NAME=value <image-name>
Run a container with multiple options

docker run -d -p 5000:5000 -v /app:/app -e ENV=prod --name myapp <image-name>
Run a container and automatically remove it after exit

docker run --rm <image-name>
Run a container with specific network

docker run --network <network-name> <image-name>
Run a container with a specific entrypoint

docker run --entrypoint <entrypoint-command> <image-name>
Run a container with CPU and memory limits

docker run --cpus="1.5" --memory="512m" <image-name>
Manage Containers
List all running containers

docker ps
List all containers (including stopped)

docker ps -a
Start a stopped container

docker start <container-id or name>
Stop a running container

docker stop <container-id or name>
Restart a container

docker restart <container-id or name>
Pause a container

docker pause <container-id or name>
Unpause a container

docker unpause <container-id or name>
Remove a stopped container

docker rm <container-id or name>
Rename a container

docker rename <old-name> <new-name>
View logs of a container

docker logs <container-id or name>
Follow logs in real-time

docker logs -f <container-id or name>
Execute a command in a running container

docker exec -it <container-id or name> <command>
Attach to a running container

docker attach <container-id or name>
Copy file from host to container

docker cp <host-path> <container-id>:<container-path>
Copy file from container to host

docker cp <container-id>:<container-path> <host-path>
Inspect container details

docker inspect <container-id or name>
Show resource usage stats for containers

docker stats
Manage Images
List all Docker images

docker images
Pull an image from Docker Hub

docker pull <image-name>
Build an image from Dockerfile

docker build -t <image-name>:<tag> .
Tag a Docker image

docker tag <source-image> <target-image>
Push an image to Docker Hub

docker push <image-name>
Remove a Docker image

docker rmi <image-id or name>
Save a Docker image to a tar file

docker save -o <filename>.tar <image-name>
Load a Docker image from a tar file

docker load -i <filename>.tar
Inspect a Docker image

docker inspect <image-id or name>
Show history of an image

docker history <image-name>
Prune unused images

docker image prune -a
Build
Build a Docker image from Dockerfile in current directory

docker build -t <image-name>:<tag> .
Build an image with no cache

docker build --no-cache -t <image-name>:<tag> .
Build an image from a specific Dockerfile

docker build -f <Dockerfile-name> -t <image-name>:<tag> .
Build an image and pass build arguments

docker build --build-arg <key>=<value> -t <image-name>:<tag> .
Build an image and specify a target stage (multi-stage builds)

docker build --target <stage-name> -t <image-name>:<tag> .
Build an image with a specific platform (e.g., for ARM)

docker build --platform linux/arm64 -t <image-name>:<tag> .
Buildx: Create a new builder instance

docker buildx create --name <builder-name> --use
Buildx: List all builders

docker buildx ls
Buildx: Build and push a multi-platform image

docker buildx build --platform linux/amd64,linux/arm64 -t <image-name>:<tag> --push .
Buildx: Inspect a builder instance

docker buildx inspect <builder-name>
Buildx: Remove a builder instance

docker buildx rm <builder-name>
Volume
Create a Docker volume

docker volume create <volume-name>
List all Docker volumes

docker volume ls
Inspect a Docker volume

docker volume inspect <volume-name>
Remove a Docker volume

docker volume rm <volume-name>
Remove all unused volumes

docker volume prune
Use a volume when running a container

docker run -d -v <volume-name>:/app/data <image-name>
Mount a volume with read-only access

docker run -d -v <volume-name>:/app/data:ro <image-name>
Copy data into a volume using a temporary container

docker run --rm -v <volume-name>:/data -v $(pwd):/backup busybox cp /backup/<file> /data/
Backup a volume to a tar file

docker run --rm -v <volume-name>:/volume -v $(pwd):/backup busybox tar cvf /backup/backup.tar /volume
Restore a volume from a tar file

docker run --rm -v <volume-name>:/volume -v $(pwd):/backup busybox tar xvf /backup/backup.tar -C /volume
Network
List all Docker networks

docker network ls
Create a new Docker network

docker network create <network-name>
Inspect a Docker network

docker network inspect <network-name>
Remove a Docker network

docker network rm <network-name>
Connect a container to a network

docker network connect <network-name> <container-name>
Disconnect a container from a network

docker network disconnect <network-name> <container-name>
Run a container with a specific network

docker run --network <network-name> <image-name>
Create a network with a specific driver (e.g., bridge, overlay)

docker network create --driver <driver-name> <network-name>
Create a user-defined bridge network

docker network create --driver bridge <network-name>
Create an overlay network (for Swarm mode)

docker network create --driver overlay <network-name>
Troubleshooting 
Check Docker version

docker --version
Check Docker system info

docker info
Check Docker service status (Linux)

systemctl status docker
Restart Docker service (Linux)

sudo systemctl restart docker
View container logs

docker logs <container-id or name>
Follow container logs in real-time

docker logs -f <container-id or name>
Execute a shell inside a running container

docker exec -it <container-id or name> /bin/bash
Inspect detailed container information

docker inspect <container-id or name>
Get container resource usage (live stats)

docker stats
Get list of failed containers (Exited)

docker ps -a --filter "status=exited"
Remove all exited containers

docker container prune
Check Docker daemon logs (Linux)

journalctl -u docker.service
Test container networking

docker exec -it <container-id> ping <target-host>
Debug Dockerfile build issues

docker build --no-cache -t <image-name> .
View events from the Docker daemon

docker events
Diagnose Docker installation

sudo docker system info
sudo docker system df
