# Stage 1: Build dependencies
FROM ubuntu:focal AS builder
ENV DEBIAN_FRONTEND=noninteractive

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

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get update && apt-get install -y nodejs

RUN groupadd -g 1001 node && useradd -u 1001 -g node -ms /bin/bash node

RUN npm install -g n8n

# Stage 2: Application image
FROM python:3.11-slim  # Use a minimal python image

COPY --from=builder /home/node/n8n /app/n8n
COPY --from=builder /home/node/.n8n /app/.n8n

RUN mkdir -p /app/venv
RUN chown -R node:node /app/.n8n /app/venv

USER node
WORKDIR /app

ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install --upgrade pip setuptools wheel numpy pyarrow dspy

EXPOSE 8080
ENV N8N_PORT=8080
ENV N8N_HOST=0.0.0.0

CMD ["n8n", "start"]
