# NFS Automounter

This repository contains a daemon designed to monitor and maintain NFS mounts listed in `/etc/fstab`.

The script periodically checks if these mounts are properly connected and, if necessary, attempts to remount them. It pings the remote server to verify connectivity and, upon successful response, tries to remount the NFS shares every 10 seconds.

Once all mounts are confirmed to be properly mounted, the check interval increases to 60 seconds to reduce system load. This allows the daemon to efficiently recover from disconnections or errors.

## Why?

I frequently encountered issues where my Proxmox containers or virtual machines couldn't connect to my OMV (OpenMediaVault) NAS. Despite numerous attempts at debugging and adjusting NFS server and client settings, I couldn't achieve a stable connection with automatic recovery.

This daemon provides a practical workaround by ensuring reconnection after a brief interval.

While not a perfect solution, it has proven effective.

## Installation

To install the NFS Automounter service on your target machine, follow the steps below:

1. **Login via SSH**:

   Use your preferred SSH client to log in to the desired target machine.
   
   Replace `user` and `hostname` with your actual username and the machine's hostname or IP address.

    ```sh
    ssh user@hostname
    ```

2. **Run the Installer Script**:

   Use `wget` to download the installer script and pipe it to `sudo sh` to execute the script with superuser privileges.
   
   This command will download and run the script in one step.

    ```sh
    wget -qO- https://raw.githubusercontent.com/alexandre-leites/nfs-automounter/main/installer.sh | sudo sh
    ```

## Uninstallation

If you need to uninstall the NFS Automounter service, follow these steps:

1. **Login via SSH**:

   Use your preferred SSH client to log in to the desired target machine.

    ```sh
    ssh user@hostname
    ```

2. **Run the Uninstaller Script**:

   Use `wget` to download the installer script and pipe it to `sudo sh` with the `-u` flag to execute the uninstallation process.

    ```sh
    wget -qO- https://raw.githubusercontent.com/alexandre-leites/nfs-automounter/main/installer.sh | sudo sh -s -u
    ```

## Future Improvements
- Implement log rotation
- Support additional mount types
