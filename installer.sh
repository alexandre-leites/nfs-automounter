#!/bin/sh

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if the script is running with sudo
if [ "$(id -u)" -ne 0 ]; then
    log_message "Please run as root."
    exit 1
fi

# Install wget if not installed
if ! command -v wget > /dev/null 2>&1; then
    log_message "wget could not be found, installing it."
    if command -v apt-get > /dev/null 2>&1; then
        apt-get update && apt-get install -y wget
    elif command -v apk > /dev/null 2>&1; then
        apk update && apk add wget
    else
        log_message "Neither apt-get nor apk found. Please install wget manually."
        exit 1
    fi
    log_message "wget installed successfully."
fi

# Detect init system
if command -v systemctl > /dev/null 2>&1; then
    INIT_SYSTEM="systemd"
elif command -v rc-update > /dev/null 2>&1; then
    INIT_SYSTEM="openrc"
else
    log_message "Unsupported init system. This script supports systemd and OpenRC."
    exit 1
fi

# Handle uninstallation
if [ "$1" = "-u" ]; then
    log_message "Uninstalling mount_nfs service."
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        if systemctl is-active --quiet mount_nfs.service; then
            systemctl stop mount_nfs.service
            log_message "Stopped mount_nfs service."
        fi
        if systemctl is-enabled --quiet mount_nfs.service; then
            systemctl disable mount_nfs.service
            log_message "Disabled mount_nfs service."
        fi
        rm -f /etc/systemd/system/mount_nfs.service
        log_message "Removed /etc/systemd/system/mount_nfs.service."
        systemctl daemon-reload
        log_message "Reloaded systemd daemon."
    elif [ "$INIT_SYSTEM" = "openrc" ]; then
        rc-service mount_nfs stop
        log_message "Stopped mount_nfs service."
        rc-update del mount_nfs default
        log_message "Removed mount_nfs service from default runlevel."
        rm -f /etc/init.d/mount_nfs
        log_message "Removed /etc/init.d/mount_nfs."
    fi
    rm -f /usr/local/bin/mount_nfs.sh
    log_message "Removed /usr/local/bin/mount_nfs.sh."
    log_message "Uninstallation complete."
    exit 0
fi

# Stop mount_nfs.service if it exists
if [ "$INIT_SYSTEM" = "systemd" ]; then
    if systemctl list-unit-files | grep -q "mount_nfs.service"; then
        systemctl stop mount_nfs.service
        log_message "Stopped mount_nfs.service."
    fi
elif [ "$INIT_SYSTEM" = "openrc" ]; then
    if rc-status | grep -q "mount_nfs"; then
        rc-service mount_nfs stop
        log_message "Stopped mount_nfs service."
    fi
fi

# Download mount_nfs.service or init.d script
if [ "$INIT_SYSTEM" = "systemd" ]; then
    wget -O /etc/systemd/system/mount_nfs.service https://raw.githubusercontent.com/alexandre-leites/nfs-automounter/main/mount_nfs.service
    log_message "Downloaded mount_nfs.service to /etc/systemd/system/mount_nfs.service."
elif [ "$INIT_SYSTEM" = "openrc" ]; then
    wget -O /etc/init.d/mount_nfs https://raw.githubusercontent.com/alexandre-leites/nfs-automounter/main/mount_nfs.initd
    log_message "Downloaded mount_nfs script to /etc/init.d/mount_nfs."
fi

# Download mount_nfs.sh
wget -O /usr/local/bin/mount_nfs.sh https://raw.githubusercontent.com/alexandre-leites/nfs-automounter/main/mount_nfs.sh
log_message "Downloaded mount_nfs.sh to /usr/local/bin/mount_nfs.sh."

# Give execution permission
chmod +x /usr/local/bin/mount_nfs.sh
log_message "Set execution permission for /usr/local/bin/mount_nfs.sh."

# Enable and start the service
if [ "$INIT_SYSTEM" = "systemd" ]; then
    systemctl daemon-reload
    log_message "Reloaded systemd daemon."
    systemctl enable mount_nfs.service
    log_message "Enabled mount_nfs.service."
    systemctl start mount_nfs.service
    log_message "Started mount_nfs.service."
elif [ "$INIT_SYSTEM" = "openrc" ]; then
    chmod +x /etc/init.d/mount_nfs
    log_message "Set execution permission for /etc/init.d/mount_nfs."
    rc-update add mount_nfs default
    log_message "Added mount_nfs service to default runlevel."
    rc-service mount_nfs start
    log_message "Started mount_nfs service."
fi

log_message "Installation complete. The mount_nfs service is now running."

exit 0
