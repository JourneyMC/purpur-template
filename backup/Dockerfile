FROM lobaro/restic-backup-docker@sha256:8057a5a6a423a6730774bdfeff0f20a87f7e2e4747c6a8720c8c2f41ca016537

# Install required packages
RUN apk add --no-cache mysql-client

ARG rcon_version=1.5.1

ADD https://github.com/itzg/rcon-cli/releases/download/${rcon_version}/rcon-cli_${rcon_version}_linux_amd64.tar.gz /tmp/rcon-cli.tar.gz

RUN mkdir -p /usr/local/bin/
RUN tar x -f /tmp/rcon-cli.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/rcon-cli
