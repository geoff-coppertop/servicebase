FROM ubuntu:18.04

ENV container docker
# Install other apt deps
RUN apt-get update && apt-get install -y --no-install-recommends    \
        systemd-sysv    \
        dbus            \
        wget            \
        git             \
    # Packages for python cffi
        python-virtualenv   \
        virtualenv          \
        python-dev          \
        libffi-dev          \
        build-essential     \
    && rm -rf /var/lib/apt/lists/*  \
# We never want these to run in a container
# Feel free to edit the list but this is the one we used
    && systemctl mask                   \
        dev-hugepages.mount             \
        sys-fs-fuse-connections.mount   \
        sys-kernel-config.mount         \
        display-manager.service         \
        getty@.service                  \
        systemd-logind.service          \
        systemd-remount-fs.service      \
        getty.target                    \
        graphical.target

COPY entry.sh /usr/bin/entry.sh
COPY app.service /etc/systemd/system/app.service

STOPSIGNAL 37

ENTRYPOINT ["/usr/bin/entry.sh"]

WORKDIR /usr/app

RUN useradd -ms /bin/bash service \
    && adduser service dialout \
    && mkdir -p /usr/app/cfg \
    && mkdir -p /usr/app/src \
    && mkdir -p /usr/app/log \
    && chown -R service:service /usr/app \
    && systemctl enable /etc/systemd/system/app.service

VOLUME /usr/app/cfg
VOLUME /usr/app/src
VOLUME /usr/app/log

USER service

RUN virtualenv venv

ENV INITSYSTEM on

USER root

# Start app
CMD ["bash", "/usr/app/src/start.sh"]