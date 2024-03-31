FROM registry.fedoraproject.org/fedora:39

#systemd recognizes "container=docker" and does not recognize ocid but it does not make any difference except for the welcome message
#avoid mentioning trademarked docker
ENV NAME=fedora-init VERSION=0.1 RELEASE=1 ARCH=x86_64 container=oci

MAINTAINER vietchinh <1348151+vietchinh@users.noreply.github.com>

CMD ["/sbin/init"]

STOPSIGNAL SIGRTMIN+3

# Align with https://catalog.redhat.com/software/containers/ubi9/ubi-init/615bdc22075b022acc111bf6?architecture=amd64&image=65e0aca88b7d6c2795cea14c&container-tabs=dockerfile
RUN systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service && \
    systemctl disable dnf-makecache.timer dnf-makecache.service && \
    dnf -y install procps-ng && \
    dnf clean all && \
    # Source: https://www.dogtagpki.org/wiki/Fedora_Container
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

ADD README.md /
