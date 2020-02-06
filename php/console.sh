#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
[[ -z ${RUNS} ]] && RUNS=0

FOREVER_RUNS=0
if [ ${RUNS} -eq 0 ]; then
    FOREVER_RUNS=1
    RUNS=1
fi

. ${DIR}/init.sh

while [ ${RUNS} -gt 0 ]; do
    ${CONSOLE} "$@" ${DEBUG_PARAMS}

    if [ ${FOREVER_RUNS} -eq 0 ]; then
        RUNS=$((${RUNS} - 1))
    fi
    if [ ${RUNS} -gt 0 ]; then
        sleep ${SLEEP}
    fi
done
