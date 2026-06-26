#!/bin/bash
set -e

function make-entrypoint() {
    # enable entrypoint
    ln -sf /etc/systemd/system/container-entrypoint.service /etc/systemd/system/multi-user.target.wants/container-entrypoint.service
}

function attach-tty() {
    # create drop-in to attach tty for container-entrypoint.service
    mkdir -p /etc/systemd/system/container-entrypoint.service.d
    cat <<EOF >/etc/systemd/system/container-entrypoint.service.d/attach-tty.conf
# tty detected
[Service]
StandardInput=tty
StandardOutput=tty
TTYPath=$1
TTYReset=yes
TTYVHangup=yes

Environment=TERM=$TERM
Environment=COLORTERM=$COLORTERM
EOF
}

function spawn-log-forwarder() {
    ( exec -a '@log-forwarder journalctl' journalctl -b 0 -f --no-tail; ) &
}

if [[ -t 0 ]]; then
    # have tty, attach it
    attach-tty "$(readlink /proc/self/fd/0)"
    make-entrypoint
else
    spawn-log-forwarder
fi
