#!/usr/bin/env bash
#
# Usage: release-notes.sh RELEASE SUMMARY_DIR
#
# Prints a Markdown table with what each image of RELEASE contains. SUMMARY_DIR
# holds one file per PostgreSQL major, named after its bake target (pg-18, ...),
# as written by tests/run.sh with SUMMARY_FILE.

set -euo pipefail

RELEASE="${1:?usage: $0 RELEASE SUMMARY_DIR}"
DIR="${2:?usage: $0 RELEASE SUMMARY_DIR}"
IMAGE="${IMAGE:-ruxwez/postgres}"

echo "| Image | PostgreSQL | Extensions |"
echo "|---|---|---|"
# Newest major first.
find "$DIR" -maxdepth 1 -type f -name 'pg-*' -printf '%f\n' | sort -t- -k2 -rn | while read -r file; do
  major="${file#pg-}"
  pg_version="$(awk '$1 == "postgresql" { print $2 }' "$DIR/$file")"
  extensions="$(awk '$1 != "postgresql" { printf "%s%s %s", sep, $1, $2; sep = " · " }' "$DIR/$file")"
  echo "| \`$IMAGE:$major-v$RELEASE\` | $pg_version | $extensions |"
done
