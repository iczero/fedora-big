#!/bin/bash
set -e

if [[ "$#" == 0 ]]; then
    has_args=0
    args=(bash)
else
    has_args=1
    args=("$@")
fi

function make-entrypoint() {
    # create entrypoint
    entrypoint="/run/entrypoint"
    echo '#!/bin/bash' >> "$entrypoint"
    printf 'exec' >> "$entrypoint"
    for arg in "${args[@]}"; do
        printf ' %s' "${arg@Q}" >> "$entrypoint"
    done
    chmod a+x "$entrypoint"
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
TTYPath=/dev/console
TTYReset=yes
TTYVHangup=yes
EOF
}

function spawn-log-forwarder() {
    ( exec -a '@log-forwarder journalctl' journalctl -b 0 -f; ) &
}

if [[ -t 0 ]]; then
    # have tty, attach it
    attach-tty
    make-entrypoint
else
    spawn-log-forwarder
    if [[ "$has_args" == 1 ]]; then
        make-entrypoint
    fi
fi
