# Credit to Julien Guyomard (https://github.com/jguyomard). This Dockerfile
# is essentially based on his Dockerfile at
# https://github.com/jguyomard/docker-hugo/blob/master/Dockerfile. The only significant
# change is that the Hugo version is now an overridable argument rather than a fixed
# environment variable.

LABEL maintainer="Luc Perkins <lperkins@linuxfoundation.org>"


FROM docker.io/library/alpine:3.20 as themes

RUN apk add --no-cache \
    openssh-client \
    git \
    npm

COPY themes /opt/themes
RUN rm -rf /opt/themes/*/.git

FROM docker.io/library/debian:bookworm

RUN apk add --no-cache \
    runuser \
    git \
    openssh-client \
    rsync

FROM docker.io/library/ubuntu:noble

RUN apt-get update && apt-get install -y \
  --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    apt-utils \
    golang-1.22 \
    golang-go

ARG HUGO_VERSION

RUN mkdir /fetch && curl -L -o /fetch/hugo_extended_${HUGO_VERSION}_linux-amd64.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb && apt-get install -y /fetch/hugo_extended_${HUGO_VERSION}_linux-amd64.deb && rm -rf /fetch

RUN useradd -m --user-group -u 60000 -d /var/hugo hugo && \
    chown -R hugo: /var/hugo && \
    runuser -u hugo -- git config --global --add safe.directory /src

COPY --from=themes /opt/themes /opt/themes

WORKDIR /src

USER hugo:hugo

EXPOSE 1313

ENTRYPOINT /usr/local/bin/hugo

CMD help
