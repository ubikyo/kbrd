#!/bin/sh

set -e

PROJECT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$PROJECT_DIR"

cleanup() {
    kill 0
}
trap cleanup INT TERM EXIT

./kbrd-api/dev.sh &
./kbrd-web/dev.sh &

wait
