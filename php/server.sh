#!/usr/bin/env bash

SKIP_DEV_SLEEP="1"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
[[ -z ${CODE_DIR} ]] && CODE_DIR="/code"
[[ -z ${ROUTER} ]] && ROUTER="${CODE_DIR}/public/index.php"

. ${DIR}/init.sh
. ${DIR}/main.sh

php -S -t ${CODE_DIR} -S 0.0.0.0:8000 ${ROUTER}
