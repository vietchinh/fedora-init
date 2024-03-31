# Sources:
# https://www.dogtagpki.org/wiki/Fedora_Container
# https://www.reddit.com/r/docker/comments/fy015c/init_systems_in_linux_containers/
# https://github.com/containers/podman/issues/16923
# https://github.com/containers/podman/blob/main/libpod/container_internal_linux.go#L195-L306
ARG FEDORA_VERSION

FROM registry.fedoraproject.org/fedora:${FEDORA_VERSION} as fedora

RUN dnf -y install procps-ng systemd --setopt=install_weak_deps=False --nodocs && \
    dnf clean all

FROM registry.fedoraproject.org/fedora-minimal:${FEDORA_VERSION} as fedora-minimal

RUN microdnf -y install procps-ng systemd --setopt=install_weak_deps=False --nodocs && \
    microdnf clean all

#systemd recognizes "container=docker" and does not recognize ocid but it does not make any difference except for the welcome message
#avoid mentioning trademarked docker
ENV NAME=fedora-init VERSION=0.1 RELEASE=1 ARCH=x86_64 container=oci

LABEL maintainer="vietchinh <1348151+vietchinh@users.noreply.github.com>"

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/var/log/journal"]
CMD ["/sbin/init"]

STOPSIGNAL SIGRTMIN+3

# Align with https://catalog.redhat.com/software/containers/ubi9/ubi-init/615bdc22075b022acc111bf6?architecture=amd64&image=65e0aca88b7d6c2795cea14c&container-tabs=dockerfile
RUN systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service && \
    systemctl disable dnf-makecache.timer dnf-makecache.service && \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

ADD README.md /
