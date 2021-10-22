FROM voidlinux/voidlinux:latest

ARG NETAUTH_HOST=""

RUN xbps-install -Su --yes \
  xbps \
  cfssl \
  NetAuth \
  NetAuth-localizer \
  NetAuth-server \
  NetAuth-pam-helper \
  NetAuth-nsscache \
  NetAuth-ldap \
  NetKeys \
  pam_netauth \
  bash \
  cronie \
  openssh \
  ncurses-term \
  socklog \
  socklog-void \
  sudo \
  node_exporter

# Install service files

COPY ./etc/sv /etc/sv

RUN chmod +x /etc/sv/localizer/run
RUN chmod +x /etc/sv/netauthd/run

# Create runsvdir
RUN mkdir -p /run/runit/runsvdir/current

# Enable services
RUN ln -sf /etc/sv/cronie /var/service/cronie
RUN ln -sf /etc/sv/sshd /var/service/
RUN ln -sf /etc/sv/localizer /var/service/
RUN ln -sf /etc/sv/socklog-unix /var/service/
RUN ln -sf /etc/sv/netauthd /var/service/
RUN ln -sf /etc/sv/netauth-ldap /var/service/
RUN ln -sf /etc/sv/node_exporter /var/service/


# Install sudoers file
COPY ./etc/sudoers /etc/sudoers
RUN chmod 0440 /etc/sudoers && chown 0:0 /etc/sudoers

# Install sshd config
COPY ./etc/ssh/sshd_config /etc/ssh/sshd_config
RUN chmod 0644 /etc/ssh/sshd_config

# Configure netauth
RUN mkdir -p /etc/netauth/keys
COPY ./etc/netauth /etc/netauth


# Install init script

ADD ./entrypoint.sh /usr/sbin/init-docker
RUN chmod +x /usr/sbin/init-docker

# netauthd
EXPOSE 1729
# LDAP
EXPOSE 389
# SSH
EXPOSE 22
# node_exporter metrics
EXPOSE 9100

ENTRYPOINT ["/usr/sbin/init-docker"]
