FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        build-essential \
        cmake \
        git \
        curl \
        gnupg \
        python3 \
        python3-pip \
        python3-dev \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v18
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

# Update package lists after adding NodeSource
RUN apt-get update

# Install Node.js
RUN apt-get install -y nodejs

# Create the node user with a different UID/GID (1001)
RUN groupadd -g 1001 node && useradd -u 1001 -g node -ms /bin/bash node

# Install n8n, create data dir, and set ownership
RUN npm install -g n8n && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

# Switch to the node user
USER node

# Set the working directory
WORKDIR /home/node

# Create and activate a virtual environment
RUN python3 -m venv /home/node/venv
ENV VIRTUAL_ENV=/home/node/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip, setuptools, and wheel
RUN pip install --upgrade pip setuptools wheel

# Install numpy (before pyarrow)
RUN pip install numpy

# Install pyarrow (using pip, which will handle the build)
RUN pip install pyarrow

# Install DSPy
RUN pip install dspy

# Expose port 8080
EXPOSE 8080
ENV N8N_PORT=8080
ENV N8N_HOST=0.0.0.0
EXPOSE 8080

# Start n8n
CMD ["n8n", "start"]
