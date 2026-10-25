#!/bin/sh
#
# Usage: pgxs-build.sh REPO REF [SUBDIR [MAKE_ARGS...]]
#
# Fetches REPO at REF (a tag or a commit) and builds it with PGXS, installing
# into /out. If MIN_PG_MAJOR is set and the PostgreSQL major is lower, does
# nothing: the extension doesn't support that major (see
# extensions/*/pg-versions).

set -eu

repo="$1"
ref="$2"
dir="${3:-.}"
shift 2
[ "$#" -gt 0 ] && shift

mkdir -p /out
if [ -n "${MIN_PG_MAJOR:-}" ] && [ "$PG_MAJOR" -lt "$MIN_PG_MAJOR" ]; then
  echo "Skipping $repo: needs PostgreSQL $MIN_PG_MAJOR+, this is $PG_MAJOR"
  exit 0
fi

src="$(mktemp -d)"
git -C "$src" init -q
git -C "$src" fetch -q --depth 1 "$repo" "$ref"
git -C "$src" checkout -q FETCH_HEAD
make -C "$src/$dir" -j"$(nproc)" "$@"
make -C "$src/$dir" install DESTDIR=/out "$@"
rm -rf "$src"
