#!/bin/bash
## usage: ./gen_issues.sh taskexec/<subproject>

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 taskexec/<subproject>" >&2
  exit 1
fi

SCOPE_ROOT="${1%/}"
OUTPUT="$SCOPE_ROOT/docs/issue_index.md"
ISSUE_DIR="$SCOPE_ROOT/docs/issues"

echo "Generating issue index..."

mkdir -p "$ISSUE_DIR"

echo "# Issue Index" > "$OUTPUT"
echo "" >> "$OUTPUT"
echo "IssueID | Priority | Status | Summary | detailFile" >> "$OUTPUT"

find "$ISSUE_DIR" -maxdepth 1 -type f -name 'ISSUE-*.md' | sort | while read file
do
  ID=$(grep -m1 '^IssueID:' "$file" | sed -E 's/^IssueID:[[:space:]]*//')
  PRIORITY=$(grep -m1 '^Priority:' "$file" | sed -E 's/^Priority:[[:space:]]*//')
  STATUS=$(grep -m1 '^Status:' "$file" | sed -E 's/^Status:[[:space:]]*//')
  SUMMARY=$(grep -m1 '^Summary:' "$file" | sed -E 's/^Summary:[[:space:]]*//')
  DETAIL=$(grep -m1 '^DetailFile:' "$file" | sed -E 's/^DetailFile:[[:space:]]*//')

  if [ -n "$ID" ]; then
    echo "$ID | $PRIORITY | $STATUS | $SUMMARY | $DETAIL" >> "$OUTPUT"
  fi
done

echo "Done."
