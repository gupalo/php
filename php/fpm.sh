#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

SKIP_DEV_SLEEP="1"
. ${DIR}/init.sh

php-fpm
