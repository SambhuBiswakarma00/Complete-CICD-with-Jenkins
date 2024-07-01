#!/bin/bash

# Script to install Prometheus on Ubuntu

# Variables
PROMETHEUS_VERSION="2.43.0" # Set to the desired Prometheus version
USER="prometheus"           # User to run Prometheus
DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

# Update the system
echo "Updating the system..."
sudo apt update -y

# Install necessary packages
echo "Installing necessary packages..."
sudo apt install -y wget tar

# Create a user for Prometheus
echo "Creating Prometheus user..."
sudo useradd --no-create-home --shell /bin/false $USER

# Create necessary directories
echo "Creating directories..."
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

# Set ownership of directories
echo "Setting ownership of directories..."
sudo chown $USER:$USER /var/lib/prometheus

# Download Prometheus
echo "Downloading Prometheus..."
cd /tmp
wget $DOWNLOAD_URL

# Extract Prometheus
echo "Extracting Prometheus..."
tar -xvf prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz

# Move Prometheus binaries
echo "Moving Prometheus binaries..."
cd prometheus-$PROMETHEUS_VERSION.linux-amd64
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/

# Move Prometheus configuration files
echo "Moving Prometheus configuration files..."
sudo mv consoles /etc/prometheus
sudo mv console_libraries /etc/prometheus
sudo mv prometheus.yml /etc/prometheus

# Set ownership of configuration files
echo "Setting ownership of configuration files..."
sudo chown -R $USER:$USER /etc/prometheus

# Create systemd service file for Prometheus
echo "Creating systemd service file..."
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply the new service file
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable and start Prometheus service
echo "Enabling and starting Prometheus service..."
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Check the status of Prometheus service
echo "Checking Prometheus service status..."
sudo systemctl status prometheus

echo "Prometheus installation completed successfully."
