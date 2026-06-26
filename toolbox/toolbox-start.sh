#!/bin/bash

image="toolbox:1"

exec podman run -d --userns=keep-id -e TERM -e COLORTERM "$@" "$image"
