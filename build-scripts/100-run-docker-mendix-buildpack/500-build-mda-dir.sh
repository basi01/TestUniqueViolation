#!/bin/bash

set -e
set -o pipefail

cd -- "${BPK_DIR:?}"

docker image inspect mendix-rootfs:app >/dev/null 2>&1 || docker build -t mendix-rootfs:app -f rootfs-app.dockerfile .
docker image inspect mendix-rootfs:builder >/dev/null 2>&1 || docker build -t mendix-rootfs:builder -f rootfs-builder.dockerfile .

./build.py --source "${MPR_DIR:?}" --destination "${MDA_DIR:?}" build-mda-dir

docker build --tag "${APP_TAG:?}" "${MDA_DIR:?}"
