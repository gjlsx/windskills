#!/bin/bash
##use these get new issue_id

INDEX_FILE="docs/issue_index.md"

LAST_ID=$(grep -oE "ISSUE-[0-9]+" $INDEX_FILE | tail -1 | cut -d '-' -f2)

if [ -z "$LAST_ID" ]; then
  NEW_ID=1
else
  NEW_ID=$((LAST_ID + 1))
fi

printf "ISSUE-%03d\n" $NEW_ID