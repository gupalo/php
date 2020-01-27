#!/usr/bin/env bash

SKIP_DEV_SLEEP="1"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
[[ -z ${CODE_DIR} ]] && CODE_DIR="/code"

. ${DIR}/init.sh
. ${DIR}/main.sh

sudo /usr/local/bin/symfony server:start --allow-http --no-tls --dir=${CODE_DIR} --port=8000