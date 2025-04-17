#!/bin/bash

BACKUP_SOURCE="/var/www"
BACKUP_DEST="~/backub_var_dir"
LOG_FILE="~/backup.log"
EMAIL="muhammedsamir342@gmail.com"
DATE=$(date +"%Y-%m-%d")
BACKUP_FILE="$BACKUP_DEST/backup-$DATE.tar.gz"

sudo mkdir -p "$BACKUP_DEST"
sudo mkdir -p "$LOG_FILE"

#backup of $BACKUP_SOURCE
{
    echo "backup of $BACKUP_SOURCE at $(date)"
    sudo tar -czf "$BACKUP_FILE" "$BACKUP_SOURCE"
    if [ $? -ne 0 ]; then
        echo "Backup failed: $BACKUP_FILE"
        echo "Backup failed for $BACKUP_SOURCE on $(date)" | mail -s "Backup Failure Alert" "$EMAIL"
        exit 1
    fi
    echo "Backup is completed successfully: $BACKUP_FILE"

    #Retention logic
    sudo find "$BACKUP_DEST" -type f -name 'backup-*.tar.gz' -mtime +7 -exec rm {} \;
    echo "Old backups cleaned up at $(date)"
}
>> "$LOG_FILE" 2>&1

#Log Rotation
{
    echo "Log rotation started at $(date)"
    if [ $(ls -1q "$LOG_FILE" | wc -l) -gt $MAX_LOG_FILES ]; then
        oldest_log=$(ls -t "$LOG_FILE" | tail -1)
        rm "$oldest_log"
    fi
    echo "Log rotation completed at $(date)"
