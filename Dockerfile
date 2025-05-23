FROM ubuntu:22.04

ENV container docker

# Install systemd (and Python3 for Ansible)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         systemd systemd-sysv dbus python3 python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Required so systemd can mount cgroups
VOLUME [ "/sys/fs/cgroup" ]

# Make sure systemd stays in the foreground
STOPSIGNAL SIGRTMIN+3
CMD ["/lib/systemd/systemd"]