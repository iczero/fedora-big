#!/bin/bash
# initialize container
set -e

# https://github.com/moby/moby/issues/46763
# if running in docker, needs --cap-add CAP_SYS_ADMIN for mounts
mounts="$(mount)"
if ! grep -F ' type cgroup2 (rw,' <<< "$mounts" >/dev/null; then
    mount -o remount,rw /sys/fs/cgroup
fi
if ! grep -F ' on /run type tmpfs ' <<< "$mounts" >/dev/null; then
    mount -t tmpfs tmpfs /run
fi
if ! grep -F ' on /tmp type tmpfs ' <<< "$mounts" >/dev/null; then
    mount -t tmpfs tmpfs /tmp
fi

# perform setup
if [[ -x /opt/container/setup.sh ]]; then
    /opt/container/setup.sh "$@"
fi

# export SYSTEMD_LOG_LEVEL=debug
# launch systemd
# need to drop CAP_SYS_ADMIN due to some annoying bug in generator execution
exec capsh --drop=CAP_SYS_ADMIN --shell=/usr/bin/env -- /lib/systemd/systemd
