FROM quay.io/fedora/fedora:42
RUN dnf do -y --setopt=install_weak_deps=False --action=install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm \
    --action=install acl attr bind-utils bzip2 capsh conntrack cpio curl dbus dnf-plugins-core ethtool file hostname htop iproute iputils less logrotate lsof mtr ncurses neovim nftables nmap-ncat openssh-clients openssh-server openssl passwd procps-ng rsync systemd tcpdump time tmux tree unzip util-linux util-linux-user wget which zip \
    --action=upgrade '*' && \
    dnf clean all -y
COPY 90-no-passwords.conf /etc/ssh/sshd_config.d/
COPY container-entrypoint.service /etc/systemd/system
COPY run-session init.sh setup.sh /opt/container/
# disable some services:
# - systemd-resolved fails to start and we don't need it in a container anyways
# - sshd-keygen@rsa.service takes too long, use ecdsa/ed25519 host keys instead
# - ldconfig is run at image creation instead of first boot
# - sshd.service is disabled in favor of sshd.socket
RUN ln -s /opt/container/run-session /usr/local/bin/ && \
    ln -s /opt/container/init.sh /usr/local/sbin/init && \
    systemctl mask var-lib-nfs-rpc_pipefs.mount getty.target ldconfig.service sshd-keygen@rsa.service systemd-user-sessions.service && \
    systemctl disable systemd-resolved.service dnf-makecache.timer sshd.service && \
    systemctl enable sshd.socket && \
    touch /var/lib/.ssh-host-keys-migration && \
    ln -s /dev/null /etc/tmpfiles.d/systemd-nologin.conf && \
    rm -rf /tmp && \
    mkdir -p /run /tmp && \
    ldconfig -X
STOPSIGNAL SIGRTMIN+3
ENTRYPOINT ["/usr/local/sbin/init"]
CMD []
