#!/bin/sh

LOGFILE="/var/log/mount_nfs.log"

# Remove the log file at the start
rm -f $LOGFILE

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

# Function to count mounts in /etc/fstab
count_fstab_mounts() {
    grep -E '^[^#]' /etc/fstab | grep -E '\s+nfs\s+|\s+nfs4\s+' | wc -l
}

# Function to count currently mounted filesystems
count_current_mounts() {
    mount | grep -E ' type nfs| type nfs4' | wc -l
}

# Start
log_message "Starting daemon..."

# Log the number of mounts found in /etc/fstab
fstab_mounts=$(count_fstab_mounts)
log_message "NFS mounts found in /etc/fstab: $fstab_mounts"

# Loop to check and mount NFS
sleep_time=10
while true; do
    # Log the number of currently mounted filesystems before execution
    current_mounts_before=$(count_current_mounts)
    log_message "Currently mounted filesystems: $current_mounts_before"

    any_failed_mount=0

    while read -r line; do
        # Skip comments and empty lines
        case "$line" in
            \#*|'') continue ;;
        esac

        # Get the details from /etc/fstab
        server=$(echo "$line" | awk '{print $1}')
        mountpoint=$(echo "$line" | awk '{print $2}')
        fstype=$(echo "$line" | awk '{print $3}')

        # Extract hostname only
        hostname=$(echo "$server" | cut -d: -f1)

        # Only process NFS entries
        if [ "$fstype" = "nfs" ] || [ "$fstype" = "nfs4" ]; then
            if ! mount | grep -q " on $mountpoint type "; then
                log_message "Trying to mount: $mountpoint"

                if ping -c 1 -W 1 "$hostname" > /dev/null 2>&1; then
                    log_message "Server available: $hostname"
                    if mount "$mountpoint"; then
                        log_message "Mounted: $mountpoint"
                    else
                        log_message "Failed to mount: $mountpoint"
                        any_failed_mount=1
                    fi
                else
                    log_message "Server not reachable: $hostname"
                    any_failed_mount=1
                fi

            fi
        fi
    done < /etc/fstab

    # Log the number of currently mounted filesystems after execution
    current_mounts_after=$(count_current_mounts)
    log_message "Mounted filesystems after execution: $current_mounts_after"

    # Adjust sleep time based on mount status
    if [ $any_failed_mount -eq 1 ]; then
        sleep_time=10
    else
        sleep_time=60
    fi

    sleep $sleep_time
done
