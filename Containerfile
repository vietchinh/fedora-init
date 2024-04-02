# Sources:
# https://www.dogtagpki.org/wiki/Fedora_Container
# https://www.reddit.com/r/docker/comments/fy015c/init_systems_in_linux_containers/
# https://github.com/containers/podman/issues/16923
# https://github.com/containers/podman/blob/main/libpod/container_internal_linux.go#L195-L306
ARG FEDORA_VERSION
ARG FEDORA_TYPE

FROM registry.fedoraproject.org/${FEDORA_TYPE}:${FEDORA_VERSION}

ARG FEDORA_TYPE
ARG FEDORA_PACKAGE_MANAGER

#systemd recognizes "container=docker" and does not recognize ocid but it does not make any difference except for the welcome message
#avoid mentioning trademarked docker
ENV NAME=${FEDORA_TYPE}-init VERSION=0.1 RELEASE=1 ARCH=x86_64 container=oci

LABEL maintainer="vietchinh <1348151+vietchinh@users.noreply.github.com>"

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/var/log/journal"]
CMD ["/sbin/init"]

STOPSIGNAL SIGRTMIN+3

RUN ${FEDORA_PACKAGE_MANAGER} -y install procps-ng systemd --setopt=install_weak_deps=False --nodocs && \
    ${FEDORA_PACKAGE_MANAGER} clean all \
    # Align with https://catalog.redhat.com/software/containers/ubi9/ubi-init/615bdc22075b022acc111bf6?architecture=amd64&image=65e0aca88b7d6c2795cea14c&container-tabs=dockerfile
    systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service && \
    systemctl disable dnf-makecache.timer || :

COPY README.md /
