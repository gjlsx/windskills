---
name: taskexec
description: Use when creating a tasklist or executing tasks from a markdown tasklist in a repository that uses local agent rules, lock files, task logs, self-review, and test-first task execution.
---

# Taskexec

## Overview

Execute tasklist-driven work in a repository that stores process rules in files. Read the local rules first, then claim work safely, verify it, and update only the allowed tasklist fields.

## When to Use

Use this skill when the repository has task management files such as:
usually in the root dir in projec:
- `.agent-rules.md`
- `tasklist_rules.md`
- `tasklistall.md`
- `tasks/locks/`
- `tasks/<agent>/`

Do not use this skill for human direct requests codeing  not driven by a tasklist.

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

a example tasklist is:
- `assets/templates/tasklist03171111.md`


For repository prerequisites and expected file layout, read `references/repo-contract.md`.

## Mode A: Build Tasklist

Use this mode when the user asks to create a new tasklist.

1. Read `.agent-rules.md` and `tasklist_rules.md`.
2. Extract the exact tasklist schema, field rules, status vocabulary, and review requirements from local rules.
   Use required tasklist structure:
   1) Overall task name
   2) Overall description
   3) Generation time
   4) Tasklist status and inheritance source
   5) Participant roles
   6) Decomposed task table
3. Keep table structure unchanged:
   `Status | TaskID | Project | Title | Description | Type | Priority | Role | Owner | Depends | module | Claim | Finish | Report | Git | Review | Score`
   Enforce field rules:
   - `TaskID`: `tYYMMDD.pXXX`
   - `Claim`: `startat:YYMMDDHHMMSS <agent> tasks/<agent>/<taskid>.md`
   - `Finish`: `finishat:YYMMDDHHMMSS`
   - `Review`: one of `pass:no-refactor-needed`, `pass:minor-refactor-done`, `partial:needs-followup`
   - `Git`: commit hash
4. Enforce status vocabulary only:
   - `todo`, `doing`, `blocked`, `partial`, `pending`, `done`, `cancelled`
5. Plan tasks with test-first principle:
   - Define expected input/output and validation path before implementation details.
6. Run the required self-review for the new tasklist before claiming it is ready.
7. registering the tasklist in `tasklistall.md`, append only the allowed entry.
8. after review ok before doing task, must had a git commit change files done  with  msg include: tasklistname + desc`,
   after commit ok, could go to next step


## Mode B: Execute Tasklist

Use this mode when the user asks to run tasks from an existing tasklist.

### Startup Sequence

1. Read required rule and memory files. Read `.agent-rules.md` , `tasklist_rules.md`,Read target tasklist
2.3.4 steps skip because it is in step 1.
5. scan `tasks/locks/` or project's lock files dir for your own lock using filename pattern: `<agent name>_<taskid>.lock`
6. if your own lock exists:
   - inspect related task status in `tasklistall.md`  or input/linkto `tasklistxxx.md` file!
   - if task is already `done` or `cancelled`, delete the lock
   - otherwise resume that task directly
7. if no active own lock exists, find first matching `todo` task for your role
8. check dependencies
9. create lock
10. claim task
11. execute
12. run tests
13. self code review
14. if refactor is needed, repeat execute -> test -> self review until no refactor is needed
15. After done a task, the executor must commit all changed files with  message describing what was done (if it is task then msg must include whole-taskid like : `codex_t03160314.p10`).
16. update tasklist ,if had commit you must update hash to the tasklist 
17. remove lock 

## Locking Rules

- Hold only one active lock at a time.
- Never take over another agent's lock.
- Use the repository's lock naming convention from local rules.  Lock file pattern: `<agent>_<taskid>.lock`
- If local rules and the current tasklist conflict, follow `.agent-rules.md` first.
- If an AI already has an unfinished lock task, it must continue that task first.

## Allowed Tasklist Updates and  File Modifications

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

Only modify files required by rule and task:
- own task log: `tasks/<agent>/...`
- own lock: `tasks/locks/<agent>_<taskid>.lock`
- allowed tasklist fields in the target tasklist file
- code/tests/docs directly required by the claimed task

## Verification Rules

- Never mark a task `done` without fresh verification evidence.
- Run the repository's required test or validation command.
- If no automated tests exist, add minimal validation or record clear manual evidence in the task report.
- Self-review must confirm:
  - requirement satisfied
  - verification passed/tests passed
  - no obvious duplicate logic left unhandled
  - naming is consistent
  - no required refactor remains
  - task log is complete

## to backup a done tasklist 
   when no point to by others directly a different dir, move it to /docs/backuptask/


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
