FROM mongo

LABEL maintainer="philip@holobuilder.com"

RUN apt-get update
RUN apt-get install -y \
    apt-transport-https \
    lsb-release \
    software-properties-common

RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

RUN apt-key \
    --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
    --keyserver packages.microsoft.com \
    --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF

RUN apt-get update
RUN apt-get install azure-cli

ENV BACKUP_FILENAME backup
ENV AZURE_CORE_COLLECT_TELEMETRY false

ADD backup.sh /
RUN chmod 0755 backup.sh

CMD ["bash","/backup.sh"]
