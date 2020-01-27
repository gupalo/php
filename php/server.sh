#!/usr/bin/env bash

SKIP_DEV_SLEEP="1"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
[[ -z ${CODE_DIR} ]] && CODE_DIR="/code"

. ${DIR}/init.sh
. ${DIR}/main.sh

if [[ $(getent passwd _www) = "" ]]; then
    sudo addgroup --force-badname _www
    sudo adduser --no-create-home --force-badname --disabled-login --disabled-password --system _www
    sudo addgroup _www _www
fi

sudo /usr/local/bin/symfony server:start --allow-http --no-tls --dir=${CODE_DIR} --port=8000
