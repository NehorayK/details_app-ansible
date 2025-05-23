FROM ubuntu:22.04

ENV container docker

# 1. Install systemd, python3 (for Ansible), sshd and curl
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      systemd systemd-sysv dbus \
      python3 python3-venv \
      openssh-server curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# 2. Configure SSHD for root login
RUN mkdir -p /var/run/sshd \
 && echo 'root:root' | chpasswd \
 && sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 3. Required so systemd can mount cgroups
VOLUME [ "/sys/fs/cgroup" ]

# 4. Expose SSH port
EXPOSE 22

# 5. Keep systemd in the foreground
STOPSIGNAL SIGRTMIN+3
CMD ["/lib/systemd/systemd"]