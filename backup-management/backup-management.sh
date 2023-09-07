#!/bin/bash

#This script requires root privilages
if [[ "${UID}" -ne 0 ]]
then 
	echo "Use sudo ${0} or run as root"
	exit 1
fi

# Determine the current user, falling back to SUDO_USER if not available
current_user=$(logname || echo "$SUDO_USER")

# Define the directory where backups will be stored
directory_name="/home/$current_user/testDir"

# Define backup directory
BACKUP_DIR="/home/${current_user}/backUps/"

# Define source directory to be backed up
SOURCE_DIR="/home/${current_user}/bashProjects/"

# Define retention policy (in days)
RETENTION_DAYS=7

# Function to perform backup
perform_backup() {
    # Create a timestamp for the backup folder
    backup_timestamp=$(date +'%Y%m%d%H%M%S')
    
    # Define the backup folder name
    backup_folder="${BACKUP_DIR}backup_${backup_timestamp}"
    
    # Create the backup directory
    mkdir -p "$backup_folder"
    
    # Use tar to create a compressed archive of the source directory
    tar -czvf "${backup_folder}/backup.tar.gz" -C "${SOURCE_DIR}" .
    
    echo "Backup completed in $backup_folder."
}

# Function to manage backup rotation and retention
manage_backups() {
    echo "Managing backups in $BACKUP_DIR..."
    
    # Check if the backup directory exists, create it if not
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Perform the backup
    perform_backup
    
    # Clean up backups older than the retention policy
    find "$BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;
    
    echo "Backup management completed."
}

# Main function
main() {
    # Call the backup management function
    manage_backups
}

# Execute the main function
main

