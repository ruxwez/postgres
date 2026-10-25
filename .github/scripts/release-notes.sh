#!/usr/bin/env bash
#
# Usage: release-notes.sh RELEASE SUMMARY_DIR
#
# Prints a Markdown table with what each image of RELEASE contains: one column
# per PostgreSQL major, one row per extension. SUMMARY_DIR holds one file per
# major, named after its bake target (pg-18, ...), as written by tests/run.sh
# with SUMMARY_FILE.

set -euo pipefail

RELEASE="${1:?usage: $0 RELEASE SUMMARY_DIR}"
DIR="${2:?usage: $0 RELEASE SUMMARY_DIR}"
IMAGE="${IMAGE:-ruxwez/postgres}"

# Newest major first.
mapfile -t majors < <(find "$DIR" -maxdepth 1 -type f -name 'pg-*' -printf '%f\n' | sed 's/^pg-//' | sort -rn)

declare -A version=()
for major in "${majors[@]}"; do
  while read -r name ver; do
    [ -n "$name" ] && version[$name,$major]="$ver"
  done <"$DIR/pg-$major"
done
mapfile -t extensions < <(for key in "${!version[@]}"; do echo "${key%,*}"; done | grep -vx postgresql | sort -u)

row() {
  local line="| $1 |"
  shift
  for cell in "$@"; do line+=" $cell |"; done
  echo "$line"
}

cells=()
for major in "${majors[@]}"; do cells+=("PG $major"); done
row "" "${cells[@]}"
row "---" "${majors[@]/*/---}"

cells=()
for major in "${majors[@]}"; do cells+=("\`$IMAGE:$major-v$RELEASE\`"); done
row "**Image**" "${cells[@]}"

for name in postgresql "${extensions[@]}"; do
  cells=()
  for major in "${majors[@]}"; do cells+=("${version[$name,$major]:-—}"); done
  row "$([ "$name" = postgresql ] && echo PostgreSQL || echo "$name")" "${cells[@]}"
done
