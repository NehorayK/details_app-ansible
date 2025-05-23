FROM ubuntu:22.04

ENV container=docker

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      systemd systemd-sysv dbus dbus-user-session \
      openssh-server python3 python3-pip curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo 'root:root' | chpasswd \
 && sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && mkdir -p /run/sshd

RUN for m in \
      dev-hugepages.mount \
      sys-kernel-config.mount \
      sys-kernel-debug.mount \
      sys-kernel-tracing.mount \
    ; do \
      systemctl mask $m; \
    done

RUN systemctl enable ssh

VOLUME [ "/sys/fs/cgroup" ]
EXPOSE 22

STOPSIGNAL SIGRTMIN+3
ENTRYPOINT ["/lib/systemd/systemd"]