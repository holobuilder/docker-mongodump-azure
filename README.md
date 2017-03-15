# docker-mongodump-azure
A Docker image performing backups via mongodump into an Azure Storage Account.

# Usage
Single-Shot-Run:
```
  docker run -d \
    --name mongodb-azure-backup \
    --link mongodb:mongodb \
    -e "MONGO_DB=<database name>" \
    -e "AZURE_CONTAINER=<storage container name>" \
    -e "AZURE_STORAGE_ACCOUNT=<storage account name>" \
    -e "AZURE_STORAGE_KEY=<storage account key>" \
    phimar/mongodump-azure
```

Scheduling using cron:
```
  echo "* 3 * * * <docker user> docker start mongodb-azure-backup" > /etc/crontab
```