#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

# Determine the script directory
SCRIPT_DIR=$(dirname $(realpath $0))
SCRIPT="$SCRIPT_DIR/mount_nfs.sh"
SERVICE="$SCRIPT_DIR/mount_nfs.service"
SYSTEMD_DIR="/etc/systemd/system"
LOGFILE="/var/log/mount_nfs.log"

# Ensure the script is executable
chmod +x $SCRIPT

# Copy the service file
cp $SERVICE $SYSTEMD_DIR

# Stop the service if it is already running
systemctl stop mount_nfs.service

# Reload systemd daemon
systemctl daemon-reload

# Enable and start the service
systemctl enable mount_nfs.service
systemctl start mount_nfs.service

echo "Installation complete. The mount_nfs service is now running."

