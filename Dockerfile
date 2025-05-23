FROM ubuntu:22.04

# install SSH + python3 so Ansible modules will work
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openssh-server \
      python3 python3-venv sudo \
 && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd \
 && echo 'root:root' | chpasswd \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/UsePAM yes/UsePAM no/'            /etc/ssh/sshd_config

EXPOSE 22

# Run SSHd in the foreground
CMD ["/usr/sbin/sshd","-D"]