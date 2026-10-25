#!/bin/sh
#
# Usage: fetch-deb.sh URL
#
# Downloads a prebuilt extension package (.deb, or a .zip containing one) and
# copies its PostgreSQL files for this major into /out. The package is only
# unpacked, not installed, so its dependency metadata doesn't matter.

set -eu

url="$1"
work="$(mktemp -d)"
mkdir -p /out

curl -fsSL --retry 5 --retry-all-errors -o "$work/pkg" "$url"
case "$url" in
  *.zip)
    unzip -q "$work/pkg" -d "$work/zip"
    deb="$(find "$work/zip" -name '*.deb' ! -name '*dbgsym*' | head -n1)" ;;
  *)
    deb="$work/pkg" ;;
esac

dpkg-deb -x "$deb" "$work/root"
for dir in "usr/lib/postgresql/$PG_MAJOR" "usr/share/postgresql/$PG_MAJOR"; do
  if [ -d "$work/root/$dir" ]; then
    mkdir -p "/out/$(dirname "$dir")"
    # -L: some packages ship symlinks into other directories of the package.
    cp -RL "$work/root/$dir" "/out/$(dirname "$dir")/"
  fi
done
rm -rf "$work"
