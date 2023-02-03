FROM registry.access.redhat.com/ubi8/ubi:8.7

USER root

RUN yum -y update \
  && yum -y install openssh-server \
  && ssh-keygen -A
#  && chmod g+r /etc/ssh/sshd_config /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ed25519_key \
#  && chmod g+r /etc/shadow

RUN mkdir -p /etc/ssh/authorized_keys/

RUN useradd -m -g users -u 2000 bkfda \
  && useradd -m -g users -u 2001 jurgeve \
  && curl -o /etc/ssh/authorized_keys/bkfda https://github.com/fdammeke.keys \
  && curl -o /etc/ssh/authorized_keys/jurgeve https://github.com/jurgen-verhasselt-cegeka.keys

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
  && sed 's@.ssh/authorized_keys@/etc/ssh/authorized_keys/%u@g' -i /etc/ssh/sshd_config \
  && echo 'Port 2222' >> /etc/ssh/sshd_config

EXPOSE 2222

CMD ["/usr/sbin/sshd", "-D"]
