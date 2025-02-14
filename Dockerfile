# Use the official Ubuntu 22.04 image as the base image
FROM ubuntu:22.04

# Use the official NVIDIA CUDA image as the base image
#FROM nvidia/cuda:12.2.1-cudnn8-runtime-ubuntu22.04

# Set the environment variable to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and dependencies
RUN apt-get update && \
    apt-get install -y wget git python3 python3.10-venv python3-pip software-properties-common bc curl python3-packaging python3-requests python3-wheel python3-setuptools  build-essential cmake libopenblas-dev liblapack-dev libx11-dev libgtk-3-dev libjpeg-dev libpng-dev libtcmalloc-minimal4
    #libgoogle-perftools-dev

# Set LD_PRELOAD for TCMalloc
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4

# Clone the stable-diffusion-webui repository
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /stable-diffusion-webui

# Set the working directory
WORKDIR /stable-diffusion-webui

# Create a new non-root user
RUN useradd -m user

# Change ownership of the stable-diffusion-webui directory to the new user
RUN chown -R user:user /stable-diffusion-webui

# Switch to the new non-root user
USER user

# Add /home/user/.local/bin to PATH environment variable
ENV PATH="/home/user/.local/bin:$PATH"

# install dependencies
RUN bash "./webui.sh" "--exit" "--skip-torch-cuda-test" "--xformers" "--medvram"

EXPOSE 7860
ENV NVIDIA_VISIBLE_DEVICES=all

# Run the web UI script on container startup
CMD ["./webui.sh", "--api", "--listen"]
