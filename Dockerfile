FROM node:lts-alpine

LABEL maintainer="philip@holobuilder.com"

RUN npm install --global azure-cli

RUN apk add libcrypto1.1 libssl1.1 --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main
RUN apk add mongodb-tools=4.0.4-r0 --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community

ENV BACKUP_FILENAME backup

ADD backup.sh /
RUN chmod 0755 backup.sh

RUN apk add --no-cache bash

CMD ["bash","/backup.sh"]
