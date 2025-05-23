FROM ubuntu:22.04

# tell systemd it's in a container
ENV container=docker

# install systemd, dbus, SSH server, Python3 for Ansible
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      systemd systemd-sysv dbus python3 python3-venv openssh-server \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# set root password and allow root login over SSH, enable password auth
RUN echo 'root:root' | chpasswd \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && mkdir -p /run/sshd

# enable SSH under systemd
RUN systemctl enable ssh

# allow systemd to mount cgroups
VOLUME [ "/sys/fs/cgroup" ]

EXPOSE 22

# systemd must run in the foreground
STOPSIGNAL SIGRTMIN+3
CMD ["/lib/systemd/systemd"]