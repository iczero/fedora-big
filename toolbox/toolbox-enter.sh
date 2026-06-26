#!/bin/bash

container_name="$1"
shift


if [[ "$#" -lt 1 ]]; then
    # default to shell if no command provided
    args=(env -C /home/devuser zsh -l)
else
    args=("$@")
fi

exec podman exec -it -e TERM -e COLORTERM "$container_name" run-session -u devuser "${args[@]}"
