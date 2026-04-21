# ISSUE-002
IssueID: ISSUE-002
Priority: [P1]
Status: RESOLVED
Summary: update agent fix-commit rule
DetailFile: docs/issues/ISSUE-002.md

## Background
- This issue tracks the repository rule hardening for bug-fix commits.
- The goal was to make bug-fix commits traceable by requiring `ISSUE-XXX` and priority in the commit message.

## Resolution
- The agent commit rule was updated so fix commits must include:
  - `ISSUE-XXX`
  - `[P0/P1/P2]`

## Evidence
- `D:\phpStudy\WWW\likeshop\.agent-rules.md`
- `D:\phpStudy\WWW\likeshop\docs\issue_index.md`
