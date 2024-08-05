#!/bin/bash

# Ensure sshpass is installed
if ! command -v sshpass &> /dev/null
then
    echo "sshpass could not be found, installing it..."
    sudo apt-get update && sudo apt-get install -y sshpass
fi

# Default values
port=22
username=root

# Parsing command line arguments
while getopts h:p:u:P: flag
do
    case "${flag}" in
        h) hostname=${OPTARG};;
        p) port=${OPTARG};;
        u) username=${OPTARG};;
        P) password=${OPTARG};;
    esac
done

# Checking if all required parameters are provided
if [ -z "$hostname" ] || [ -z "$password" ]; then
    echo "Usage: ./installer.sh -h hostname [-p port] [-u username] -P password"
    exit 1
fi

# Ensure required files are present in the current directory
for file in setup.sh mount_nfs.service mount_nfs.sh
do
    if [ ! -f "$file" ]; then
        echo "File $file not found in the current directory. Please ensure all required files are present."
        exit 1
    fi
done

# Test SSH connection
sshpass -p "$password" ssh -o StrictHostKeyChecking=no -p $port $username@$hostname "exit"
if [ $? -ne 0 ]; then
    echo "Error: Unable to connect to host $hostname on port $port as user $username."
    exit 1
fi

# Create commands to execute on the remote machine
remote_commands=$(cat <<EOF
mkdir -p /opt/automounter
exit
EOF
)

# Executing commands on the remote machine to create the directory
sshpass -p "$password" ssh -o StrictHostKeyChecking=no -p $port $username@$hostname "$remote_commands"

# Upload the files to the remote machine
sshpass -p "$password" scp -P $port setup.sh $username@$hostname:/opt/automounter/
sshpass -p "$password" scp -P $port mount_nfs.service $username@$hostname:/opt/automounter/
sshpass -p "$password" scp -P $port mount_nfs.sh $username@$hostname:/opt/automounter/

# Create commands to change permissions and execute the setup script on the remote machine
remote_commands=$(cat <<EOF
cd /opt/automounter
chmod +x setup.sh mount_nfs.sh
./setup.sh
EOF
)

# Executing commands on the remote machine
sshpass -p "$password" ssh -o StrictHostKeyChecking=no -p $port $username@$hostname "$remote_commands"

echo "Installation completed."

