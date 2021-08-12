ARG TAG=latest

FROM ubuntu:$TAG

LABEL maintainer="Ricardo Sanchez"

ENV container=docker
ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y rsyslog systemd systemd-cron sudo iproute2 apt-utils python3 && \
    apt-get clean && \
    rm -rf /usr/share/doc/* /usr/share/man/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

RUN cd /lib/systemd/system/sysinit.target.wants/  && \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/*  \
    /lib/systemd/system/anaconda.target.wants/*  \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]

CMD ["/sbin/init", "--log-target=journal"]
