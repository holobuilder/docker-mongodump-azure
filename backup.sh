#!/bin/bash
set -e

DATETIME=`date +"%Y-%m-%d-%H-%M-%S"`

FILENAME=${BACKUP_FILENAME}
MONGO_HOST=${MONGODB_HOST:=$MONGODB_PORT_27017_TCP_ADDR}
MONGO_DB=${MONGODB_DB}
MONGO_URI=${MONGO_URI}

BACKUP_NAME="$FILENAME-$MONGO_DB-$DATETIME"
BACKUP_FOLDER="/tmp/$BACKUP_NAME/"

make_backup() {

  mkdir "$BACKUP_FOLDER"

  if [[-n "$MONGO_URI" ]]; then
    mongodump --uri $MONGO_URI -o $BACKUP_FOLDER
  else
    # if 'MONGO_DB' is empty then backup all databases
    if [[ -n "$MONGO_DB" ]]; then
      mongodump -h $MONGO_HOST -d $MONGO_DB -o $BACKUP_FOLDER
    else
      mongodump -h $MONGO_HOST -o $BACKUP_FOLDER
    fi
  fi

  tar -zcvf $BACKUP_NAME.tgz -C /tmp/ $BACKUP_NAME
}

AZURE_CONTAINER=${AZURE_CONTAINER}
AZURE_STORAGE_ACCOUNT=${AZURE_STORAGE_ACCOUNT}
AZURE_STORAGE_KEY=${AZURE_STORAGE_KEY}
AZURE_ENDPOINT_SUFFIX=${AZURE_ENDPOINT_SUFFIX:-blob.core.windows.net}

AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;AccountName=$AZURE_STORAGE_ACCOUNT;AccountKey=$AZURE_STORAGE_KEY;EndpointSuffix=$AZURE_ENDPOINT_SUFFIX"

upload_backup() {

  # Create container if it doesn't exist yet (upload fails otherwise)
  set +e
  grep -wq $AZURE_CONTAINER <<< $(az storage container list --connection-string $AZURE_STORAGE_CONNECTION_STRING)
  CONTAINER_EXISTS=$?
  set -e
  if [ "$CONTAINER_EXISTS" -gt "0" ]; then
    az storage container create -n $AZURE_CONTAINER --connection-string $AZURE_STORAGE_CONNECTION_STRING
  fi

  az storage blob upload -f $BACKUP_NAME.tgz -n $BACKUP_NAME.tgz -c $AZURE_CONTAINER --connection-string $AZURE_STORAGE_CONNECTION_STRING

}

make_backup
upload_backup
