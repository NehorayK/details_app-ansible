# details_app-ansible/Dockerfile
FROM ubuntu:22.04

# install sshd, Python3, pip, Docker CLI, curl
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openssh-server python3 python3-pip docker.io curl \
 && pip3 install docker \
 && rm -rf /var/lib/apt/lists/*

# configure SSHD
RUN mkdir -p /var/run/sshd \
 && echo 'root:root' | chpasswd \
 && sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# expose SSH, mount Docker socket
EXPOSE 22
VOLUME [ "/var/run/docker.sock" ]

# keep sshd in the foreground
CMD ["/usr/sbin/sshd","-D"]