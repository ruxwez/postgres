#!/bin/sh
#
# Prints "name version" for every extension available to PostgreSQL, read from
# the .control files (default_version may be quoted or not).

set -eu

for control in /usr/share/postgresql/"$PG_MAJOR"/extension/*.control; do
  version="$(sed -n "s/^[[:space:]]*default_version[[:space:]]*=[[:space:]]*['\"]\{0,1\}\([^'\"[:space:]]*\).*/\1/p" "$control")"
  echo "$(basename "$control" .control) ${version:--}"
done | sort
