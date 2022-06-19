#!/bin/bash

export HOME=/home/ubuntu/

HOST=$(curl http://169.254.169.254/latest/meta-data/hostname)

# DB name
DBNAME=testdb

# S3 bucket name
BUCKET=harry-mongodb-backup-s3

# Linux user account
USER=ubuntu

# Current time
TIME=`/bin/date +%d-%m-%Y-%T`

# Backup directory
DEST=/home/$USER/backup

# Tar file of backup directory
TAR=$DEST/../$TIME.tar

# Create backup dir (-p to avoid warning if already exists)
sudo mkdir -p $DEST

# Log
echo "Backing up $HOST/$DBNAME to s3://$BUCKET/ on $TIME";

# Dump from mongodb host into backup directory
sudo mongodump -h $HOST -d $DBNAME -o $DEST

# Create tar of backup directory
sudo tar cvf $TAR -C $DEST .

# Upload tar to s3
aws s3 cp $TAR s3://$BUCKET/ --storage-class STANDARD_IA

# Remove tar file locally
# rm -f $TAR

# Remove backup directory
# rm -rf $DEST

# All done
echo "Backup available at https://s3.amazonaws.com/$BUCKET/$TIME.tar"