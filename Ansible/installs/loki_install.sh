#!/bin/bash

# Script to install Loki on Ubuntu

# Variables
LOKI_VERSION="2.7.1" # Set to the desired Loki version
USER="loki"          # User to run Loki
DOWNLOAD_URL="https://github.com/grafana/loki/releases/download/v$LOKI_VERSION/loki-linux-amd64.zip"
CONFIG_URL="https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml"

# Update the system
echo "Updating the system..."
sudo apt update -y

# Install necessary packages
echo "Installing necessary packages..."
sudo apt install -y wget unzip

# Create a user for Loki
echo "Creating Loki user..."
sudo useradd --no-create-home --shell /bin/false $USER

# Create necessary directories
echo "Creating directories..."
sudo mkdir -p /etc/loki
sudo mkdir -p /var/lib/loki

# Set ownership of directories
echo "Setting ownership of directories..."
sudo chown $USER:$USER /var/lib/loki

# Download Loki
echo "Downloading Loki..."
cd /tmp
wget $DOWNLOAD_URL -O loki.zip

# Extract Loki
echo "Extracting Loki..."
unzip loki.zip
sudo mv loki-linux-amd64 /usr/local/bin/loki
sudo chmod +x /usr/local/bin/loki

# Download Loki configuration file
echo "Downloading Loki configuration file..."
wget $CONFIG_URL -O /tmp/loki-local-config.yaml
sudo mv /tmp/loki-local-config.yaml /etc/loki/loki-local-config.yaml

# Set ownership of configuration file
echo "Setting ownership of configuration file..."
sudo chown $USER:$USER /etc/loki/loki-local-config.yaml

# Create systemd service file for Loki
echo "Creating systemd service file..."
sudo tee /etc/systemd/system/loki.service > /dev/null <<EOF
[Unit]
Description=Loki
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/loki -config.file /etc/loki/loki-local-config.yaml

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply the new service file
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable and start Loki service
echo "Enabling and starting Loki service..."
sudo systemctl enable loki
sudo systemctl start loki

# Check the status of Loki service
echo "Checking Loki service status..."
sudo systemctl status loki

echo "Loki installation completed successfully."
