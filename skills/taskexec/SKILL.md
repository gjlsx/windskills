---
name: taskexec
description: Use when creating a tasklist or executing tasks from a markdown tasklist in a repository that uses local agent rules, lock files, task logs, self-review, and test-first task execution.
---

# Taskexec

## Overview

Execute tasklist-driven work in a repository that stores process rules in files. Read the local rules first, then claim work safely, verify it, and update only the allowed tasklist fields.

## When to Use

Use this skill when the repository has task management files such as:

- `.agent-rules.md`
- `tasklist_rules.md`
- `tasklistall.md`
- `tasks/locks/`
- `tasks/<agent>/`

Do not use this skill for ad-hoc coding requests that are not driven by a tasklist.

## Required Inputs

Read these files in order before taking action:

1. Repository-root `.agent-rules.md`
2. Repository-root `tasklist_rules.md`
3. The target tasklist file named by the user
4. If no tasklist file was provided, repository-root `tasklistall.md`
5. `memorys/global.md` if it exists
6. Project memory referenced by the global memory file or local rules, if it exists

If a required rule file is missing, stop and report the missing file instead of guessing.

If the repository is being set up for taskexec for the first time, bootstrap local rule files from these bundled templates:

- `assets/templates/.agent-rules.md`
- `assets/templates/tasklist_rules.md`

For repository prerequisites and expected file layout, read `references/repo-contract.md`.

## Mode A: Build Tasklist

Use this mode when the user asks to create a new tasklist.

1. Read `.agent-rules.md` and `tasklist_rules.md`.
2. Extract the exact tasklist schema, field rules, status vocabulary, and review requirements from local rules.
3. Build the tasklist in the repository's required markdown structure.
4. Keep the task table columns exactly as defined by local rules.
5. Plan tasks with test-first intent:
   - define expected behavior
   - define validation path
   - then define implementation work
6. Run the required self-review for the new tasklist before claiming it is ready.
7. If the repository requires registering the tasklist in `tasklistall.md`, append only the allowed entry.

## Mode B: Execute Tasklist

Use this mode when the user asks to run tasks from an existing tasklist.

### Startup Sequence

1. Read required rule and memory files.
2. Scan `tasks/locks/` for your own active lock.
3. If your own unfinished lock exists, resume that task first.
4. If no own active lock exists, select the first eligible task for your role from the target tasklist.
5. Check task dependencies before claiming work.
6. Confirm no other agent lock exists for the same task.
7. Create your lock.
8. Claim the task in the tasklist.
9. Execute the task.
10. Run the required verification.
11. Perform self-review.
12. If refactor is required, repeat execute -> verify -> self-review.
13. Update only the allowed tasklist fields.
14. Remove your lock.

## Locking Rules

- Hold only one active lock at a time.
- Never take over another agent's lock.
- Use the repository's lock naming convention from local rules.
- If local rules and the current tasklist conflict, follow `.agent-rules.md` first.

## Allowed Tasklist Updates

As an executor, update only the fields allowed by local rules. In most repositories these are:

- `Owner`
- `Status`
- `Claim`
- `Finish`
- `Report`
- `Git`
- `Review`
- `Score`

Do not modify the tasklist table structure unless the user explicitly asked you to redesign the tasklist format.

## Verification Rules

- Never mark a task `done` without fresh verification evidence.
- Run the repository's required test or validation command.
- If no automated tests exist, record minimal manual validation evidence in the task report.
- Self-review must confirm:
  - requirement satisfied
  - verification passed
  - no obvious duplicate logic left unhandled
  - naming is consistent
  - no required refactor remains
  - task log is complete

## Quick Reference

- Build tasklist: read rules -> create tasklist -> self-review -> register if required
- Execute task: read rules -> inspect locks -> claim -> implement -> verify -> self-review -> update tasklist -> unlock
- Missing rule files: stop and report
- Existing own lock: resume before starting new work

## Common Mistakes

- Hardcoding absolute paths from one repository into the skill
- Updating tasklist columns that local rules did not authorize
- Claiming a task before checking dependencies or other-agent locks
- Marking `done` after implementation but before verification
- Ignoring repository-specific commit or reporting rules in `.agent-rules.md`

## Example Invocations

- `Use taskexec to run docs/backuptask/tasklist03200058.md`
- `Use taskexec to build tasklist, "Refactor checkout discount flow with tests first"`

## Bootstrapping A New Repository

When a repository wants to adopt this workflow but does not yet have local rule files:

1. Copy `assets/templates/.agent-rules.md` to the repository root.
2. Copy `assets/templates/tasklist_rules.md` to the repository root.
3. Adapt agent names, commit rules, tasklist columns, and memory paths to the repository.
4. Only then start building or executing tasklists with this skill.
