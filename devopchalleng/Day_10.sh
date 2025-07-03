🔹 Challenge 1: Build a Multi-Arch Image Supporting linux/amd64, linux/arm64, and linux/arm/v7

1.	Install Docker Buildx:
o	Ensure Docker Buildx is installed and enabled. It’s included with Docker Desktop by default. For Linux, you may need to enable it:
bash
Copy
docker buildx create --use
2.	Create a Dockerfile:
o	Write a simple Dockerfile. For example:
Dockerfile
Copy
FROM alpine:latest
CMD echo "Hello, multi-arch world!"
3.	Build the Multi-Arch Image:
o	Use docker buildx to build for multiple architectures:
bash
Copy
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t your-dockerhub-username/multi-arch-demo:latest --push .
o	The --push flag pushes the image directly to Docker Hub.

🔹 Challenge 2: Push the Multi-Arch Image to Docker Hub & Verify the Docker Manifest

1.	Push the Image:
o	If you didn’t use --push in the previous step, push the image manually:
bash
Copy
docker push your-dockerhub-username/multi-arch-demo:latest
2.	Verify the Manifest:
o	Use docker manifest inspect to verify the multi-arch support:
bash
Copy
docker manifest inspect your-dockerhub-username/multi-arch-demo:latest
o	Look for entries under manifests to confirm support for amd64, arm64, and arm/v7.

🔹 Challenge 3: Deploy the Multi-Arch Image on AWS Graviton (ARM64) & a Regular EC2 x86_64 Server

1.	Launch EC2 Instances:
o	Launch an ARM64-based Graviton instance and an x86_64 instance on AWS.
2.	Install Docker:
o	Install Docker on both instances:
bash
Copy
sudo apt update
sudo apt install docker.io -y
3.	Run the Multi-Arch Image:
o	On both instances, pull and run the image:
bash
Copy
docker run --rm your-dockerhub-username/multi-arch-demo:latest
o	Verify the output matches the architecture of the instance.

🔹 Challenge 4: Use Docker Squash (--squash) to Minimize the Image Size While Keeping Multi-Arch Support

1.	Enable Experimental Features:
o	Edit /etc/docker/daemon.json to enable experimental features:
json
Copy
{
  "experimental": true
}
o	Restart Docker:
bash
Copy
sudo systemctl restart docker
2.	Build with --squash:
o	Use docker buildx with the --squash flag:
bash
Copy
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t your-dockerhub-username/multi-arch-demo:squashed --squash --push .
3.	Verify Image Size:
o	Compare the size of the squashed image with the original:
bash
Copy
docker images your-dockerhub-username/multi-arch-demo

🔹 Challenge 5: Build a Multi-Arch Alpine-Based Image with a Minimal Footprint

1.	Use Alpine as the Base Image:
o	Modify your Dockerfile to use Alpine:
Dockerfile
Copy
FROM alpine:latest
CMD echo "Hello, minimal multi-arch Alpine world!"
2.	Build the Multi-Arch Image:
o	Use docker buildx to build for multiple architectures:
bash
Copy
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t your-dockerhub-username/alpine-multi-arch:latest --push .
3.	Verify the Image Size:
o	Check the size of the Alpine-based image:
bash
Copy
docker images your-dockerhub-username/alpine-multi-arch

🔹 Challenge 6: Deploy a Raspberry Pi-Specific Multi-Arch Image and Verify Execution

1.	Build for Raspberry Pi:
o	Raspberry Pi typically uses linux/arm/v7 or linux/arm64. Ensure your image supports these architectures.
2.	Deploy on Raspberry Pi:
o	Install Docker on your Raspberry Pi:
bash
Copy
curl -sSL https://get.docker.com | sh
o	Pull and run the multi-arch image:
bash
Copy
docker run --rm your-dockerhub-username/multi-arch-demo:latest
3.	Verify Execution:
o	Check the output to confirm the image runs correctly on the Raspberry Pi.


