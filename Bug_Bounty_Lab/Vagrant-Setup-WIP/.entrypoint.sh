#!/usr/bin/env bash
[[ "$USER_ID" == "$(id -u penelope)" && "$GROUP_ID" == "$(id -g penelope)" ]] || usermod --uid "$USER_ID" --gid "$GROUP_ID" penelope
exec sudo --user penelope -- "$@"
