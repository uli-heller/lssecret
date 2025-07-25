#!/bin/sh

VERSION_MAJOR="$(head -1 VERSION.txt)"
VERSION_MINOR="$(tail -1 VERSION.txt)~$(date +%Y%m%d)"

mkdir -p build-deb/DEBIAN || exit 1
cp -a debian/* build-deb/DEBIAN/.

set -x
for p in libsecret-1-dev; do
    test -z "$(dpkg-query -W -f '${Version}' "${p}")" && {
	sudo apt update
	sudo apt-get install -y "${p}"
    }
done

#PATH="/usr/lib/go-1.23/bin:$PATH"

#test -d "age-${VERSION_MAJOR}" || {
#  gzip -cd "age-${VERSION_MAJOR}.tar.gz" | tar xf -
#}

#( cd "age-${VERSION_MAJOR}"; mkdir build-output; go build -o "./build-output" -ldflags "-X main.Version=${VERSION_MAJOR}" -trimpath ./cmd/... )

make

mkdir -p build-deb/usr/bin
install -m755 "lssecret" build-deb/usr/bin/lssecret

test -d rootfs && {
  cp -a rootfs/* build-deb/.
}

sed -i -e "s/^Version:.*$/Version: ${VERSION_MAJOR}~${VERSION_MINOR}/" build-deb/DEBIAN/control

find build-deb -name "*~"|xargs -r rm -f

dpkg-deb --build --root-owner-group build-deb dptools-lssecret_${VERSION_MAJOR}~${VERSION_MINOR}_$(uname -i).deb

rm -rf build-deb
