#!/bin/bash

if [[ $# == 1 && $1 =~ \.(lambda_)?handler$ ]]; then
    exec /lambda-entrypoint.sh "$@"
else
    exec /buildenv-entrypoint.sh "$@"
fi
