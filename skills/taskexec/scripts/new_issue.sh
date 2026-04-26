#!/bin/bash
## usage: ./new_issue.sh taskexec/<subproject>

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 taskexec/<subproject>" >&2
  exit 1
fi

SCOPE_ROOT="${1%/}"
INDEX_FILE="$SCOPE_ROOT/docs/issue_index.md"

mkdir -p "$SCOPE_ROOT/docs/issues"

if [ ! -f "$INDEX_FILE" ]; then
  printf "# Issue Index\n\nIssueID | Priority | Status | Summary | detailFile\n" > "$INDEX_FILE"
fi

LAST_ID=$(grep -oE "ISSUE-[0-9]+" "$INDEX_FILE" | tail -1 | cut -d '-' -f2)

if [ -z "$LAST_ID" ]; then
  NEW_ID=1
else
  NEW_ID=$((LAST_ID + 1))
fi

printf "ISSUE-%03d\n" "$NEW_ID"
