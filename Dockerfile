FROM mhart/alpine-node

LABEL maintainer "philip.martzok@gmail.com"

RUN npm install --global azure-cli

RUN \
    echo http://dl-3.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    echo http://dl-3.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    apk add --no-cache mongodb-tools && \
    rm /usr/bin/mongotop /usr/bin/mongoexport /usr/bin/mongorestore /usr/bin/mongostat /usr/bin/mongofiles /usr/bin/mongoimport /usr/bin/mongooplog /usr/bin/bsondump

ENV BACKUP_FILENAME backup

ADD backup.sh /
RUN chmod 0755 backup.sh

CMD ["/backup.sh"]
ENTRYPOINT ["/bin/sh"]
