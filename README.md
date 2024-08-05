# NFS Automounter

This repository contains a daemon designed to monitor and maintain NFS mounts listed in `/etc/fstab`.

The script periodically checks if these mounts are properly connected and, if necessary, attempts to remount them. It pings the remote server to verify connectivity and, upon successful response, tries to remount the NFS shares every 10 seconds.

Once all mounts are confirmed to be properly mounted, the check interval increases to 60 seconds to reduce system load. This allows the daemon to efficiently recover from disconnections or errors.

## Why?

I frequently encountered issues where my Proxmox containers or virtual machines couldn't connect to my OMV (OpenMediaVault) NAS. Despite numerous attempts at debugging and adjusting NFS server and client settings, I couldn't achieve a stable connection with automatic recovery.

This daemon provides a practical workaround by ensuring reconnection after a brief interval.

While not a perfect solution, it has proven effective.

## Installation

1. **Clone the Repository:**

   Clone the repository to any Unix machine (e.g., your local machine or a host server) using the following command:
   ```sh
   git clone <repository-url>
   ```

2. **Set Permissions:**

   Grant execution permission to the setup script:
   ```sh
   chmod +x installer.sh
   ```

3. **Run the Installer:**

   To install the daemon on the target system, execute the following command:
   ```sh
   sudo ./installer.sh -h <hostname> [-p <port>] [-u <username>] -P <password>
   ```
   * -h `<hostname>`: Specify the hostname of the target machine.
   * -p `<port>` (optional): Specify the port number (default is usually 22 for SSH).
   * -u `<username>`: Specify the username for the target machine.
   * -P `<password>`: Specify the password for the target machine.

Replace `<repository-url>`, `<hostname>`, `<port>`, `<username>`, and `<password>` with the appropriate values for your setup.


## Future Improvements
- Implement log rotation
- Support additional mount types
