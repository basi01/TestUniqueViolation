#!/bin/bash

set -e
set -o pipefail

cd -- "${BPK_DIR:?}"

docker image inspect mendix-rootfs:app >/dev/null 2>&1 || docker build -t mendix-rootfs:app -f rootfs-app.dockerfile .
docker image inspect mendix-rootfs:builder >/dev/null 2>&1 || docker build -t mendix-rootfs:builder -f rootfs-builder.dockerfile .

# This too requires a working docker executable (host, DoD, or DinD)
./build.py --source "${MPR_DIR:?}" --destination "${MDA_DIR:?}" build-mda-dir

if true; then

# - make compilation.py honor BUILDPACK_XTRACE
# - really cache downloaded Adoptium-jre-*.tar.gz and mendix-*.tar.gz 
sed -b -i \
  -e 's,    ./compilation.py,    sed -b -i "s/level=logging.INFO/level=util.get_buildpack_loglevel()/" ./compilation.py \&\&\\\n&,' "${MDA_DIR:?}/Dockerfile" \
  -e 's;^RUN \(mkdir -p /tmp/buildcache/bust\);RUN --mount=type=cache,target=/tmp/dockercache,id=docker-mendix-buildpack rm -rf /tmp/buildcache/bust \&\& ln -sTf ../dockercache /tmp/buildcache/bust \&\& \1;' \
  -e 's;\(rm -fr /tmp/buildcache\);rm -f /tmp/buildcache/bust \&\& \1;' \
  "${MDA_DIR:?}/Dockerfile"

fi

#cat /workdir/src/build-scripts/zzz-internal/patched/Dockerfile >"${MDA_DIR:?}/Dockerfile"


docker build \
  --build-arg BUILDPACK_XTRACE \
  --tag "${APP_TAG:?}" "${MDA_DIR:?}"

echo "successfully built image: ${APP_TAG:?}"
