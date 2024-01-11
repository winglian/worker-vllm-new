# Base image
# The following docker base image is recommended by VLLM:
FROM runpod/pytorch:2.1.1-py3.10-cuda12.1.1-devel-ubuntu22.04

# Use bash shell with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set the working directory
WORKDIR /

# Update and upgrade the system packages (Worker Template)
ARG DEBIAN_FRONTEND=noninteractive
RUN pip install -U torch==2.1.1 -f https://download.pytorch.org/whl/cu121
COPY builder/setup.sh /setup.sh
RUN chmod +x /setup.sh && \
    /setup.sh && \
    rm /setup.sh

# Install Python dependencies (Worker Template)
COPY builder/requirements.txt /requirements.txt
RUN pip install --upgrade pip && \
    pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

# Add src files (Worker Template)
ADD src .

# Quick temporary updates
# RUN pip install git+https://github.com/winglian/runpod-python@vllm-streaming#egg=runpod --compile

# Prepare the models inside the docker image
ENV HF_DATASETS_CACHE="/runpod-volume/huggingface-cache/datasets"
ENV HUGGINGFACE_HUB_CACHE="/runpod-volume/huggingface-cache/hub"
ENV TRANSFORMERS_CACHE="/runpod-volume/huggingface-cache/hub"

# Start the handler
ENTRYPOINT [ "/entrypoint.sh" ]

# Call your file when your container starts
CMD [ "python3", "-u", "/handler.py" ]
