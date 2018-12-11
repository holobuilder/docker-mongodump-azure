FROM node:lts-alpine

LABEL maintainer="philip@holobuilder.com"

RUN npm install --global azure-cli

ADD bin/mongodump /
RUN chmod 0755 /mongodump

ENV BACKUP_FILENAME backup

ADD backup.sh /
RUN chmod 0755 backup.sh

RUN apk add --update bash

CMD ["bash","/backup.sh"]
