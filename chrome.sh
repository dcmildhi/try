#!/bin/bash

# Update and install dependencies
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y curl ca-certificates

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -L "https://github.com/docker/compose/releases/download/$VER/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Set up Chromium directory
mkdir -p ~/chromium
cd ~/chromium

# Create docker-compose.yml
cat <<EOF > docker-compose.yml
version: "3.8"
services:
  chromium:
    image: lscr.io/linuxserver/chromium:latest
    container_name: chromium_browser
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kolkata  # Set timezone
    ports:
      - "3050:3000"
      - "3051:3001"
    security_opt:
      - seccomp:unconfined
    volumes:
      - ~/chromium/config:/config
    shm_size: "1gb"
    restart: unless-stopped
EOF

# Start Chromium container
docker-compose up -d

echo "Chromium container setup completed! Access it via http://<ipaddress>:3050"
