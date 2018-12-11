#!/bin/bash
set -e

DATETIME=`date +"%Y-%m-%d-%H-%M-%S"`

FILENAME=${BACKUP_FILENAME}
MONGO_HOST=${MONGODB_HOST:=$MONGODB_PORT_27017_TCP_ADDR}
MONGO_DB=${MONGODB_DB}

BACKUP_NAME="$FILENAME-$MONGO_DB-$DATETIME"
BACKUP_FOLDER="/tmp/$BACKUP_NAME/"

make_backup() {

  mkdir "$BACKUP_FOLDER"

  # if 'MONGO_DB' is empty then backup all databases
  if [[ -n "$MONGO_DB" ]]; then
    /mongodump -h $MONGO_HOST -d $MONGO_DB -o $BACKUP_FOLDER
  else 
    /mongodump -h $MONGO_HOST -o $BACKUP_FOLDER
  fi

  tar -zcvf $BACKUP_NAME.tgz -C /tmp/ $BACKUP_NAME
}

AZURE_CONTAINER=${AZURE_CONTAINER}
AZURE_STORAGE_ACCOUNT=${AZURE_STORAGE_ACCOUNT}
AZURE_STORAGE_KEY=${AZURE_STORAGE_KEY}

AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;BlobEndpoint=https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/;AccountName=$AZURE_STORAGE_ACCOUNT;AccountKey=$AZURE_STORAGE_KEY"

upload_backup() {
  # Send to cloud storage
  azure telemetry --disable

  # Create container if it doesn't exist yet (upload fails otherwise)
  set +e
  grep -wq $AZURE_CONTAINER <<< $(azure storage container list -c $AZURE_STORAGE_CONNECTION_STRING)
  CONTAINER_EXISTS=$?
  set -e
  if [ "$CONTAINER_EXISTS" -gt "0" ]; then
    azure storage container create $AZURE_CONTAINER -c $AZURE_STORAGE_CONNECTION_STRING
  fi

  azure storage blob upload -q $BACKUP_NAME.tgz $AZURE_CONTAINER -c $AZURE_STORAGE_CONNECTION_STRING

}

make_backup
upload_backup
