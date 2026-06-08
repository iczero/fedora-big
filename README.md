# fedora-big

Run in docker: `--security-opt writable-cgroups=true --tmpfs /tmp:exec --tmpfs /run:exec`

No additional arguments should be needed to run in podman.

## krun

`podman run -e KRUN_INIT_PID1=1 ...` should work. Not-so-micro VMs.
