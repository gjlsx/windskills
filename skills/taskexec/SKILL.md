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
4. If no tasklist file was provided, repository-root `tasklistall.md` as the default tasklist index
5. `memorys/global.md` as the default global memory file, if it exists
6. Project memory referenced by the global memory file or local rules, if it exists

Default paths and configuration:

- Repository-local default paths and tasklist resolution rules are defined in the repository's own `.agent-rules.md`.
- On first run, bootstrap `.agent-rules.md` from `assets/templates/.agent-rules.md` and use it as the single source of truth for path layout and tasklist resolution.

All formatting rules for tasks (TaskID `tMMDDhhmm.pXXX`, status vocabulary, columns) are defined exclusively in `tasklist_rules.md`.

**Initialization**: If the repository is being set up for taskexec for the first time (files are missing), you must bootstrap them:
- Copy `assets/templates/.agent-rules.md` and `assets/templates/tasklist_rules.md` to the root directory.
- Create the files/directories required by the repository's `.agent-rules.md`.
- Write the active default/custom paths into the repository's `.agent-rules.md`.
- When building the first tasklist, create `tasklistMMDDhhmm.md`.

a example tasklist is:
- `assets/templates/tasklist03171111.md`


For repository prerequisites and expected file layout, read `references/repo-contract.md`.

## Mode A: Build Tasklist

Use this mode when the user asks to create a new tasklist.

1. Read `.agent-rules.md` and `tasklist_rules.md`.
2. Extract the exact tasklist schema, field rules, status vocabulary, and review requirements from `tasklist_rules.md`.
3. `tasklist_rules.md` is the single source of truth for the tasklist structure, fixed columns, status vocabulary, and `TaskID` (`tMMDDhhmm.pXXX`). Do not rely on duplicate details here.
4. Plan tasks with test-first principle:
   - Define expected input/output and validation path before implementation details.
5. Run the required self-review for the new tasklist before claiming it is ready.
6. registering the tasklist in `tasklistall.md` as an index, append only the allowed entry.
7. after review ok before doing task, must had a git commit change files done with msg include: `tasklist filename + overall task title/description`,
   after commit ok, could go to next step


## Mode B: Execute Tasklist

Use this mode when the user asks to run tasks from an existing tasklist.

### Startup Sequence

1. Read required rule and memory files. Read `.agent-rules.md`, `tasklist_rules.md`, and read the target tasklist file named by the user.
2. If no target tasklist file was provided, read `tasklistall.md` as the default index and resolve the target concrete `tasklistMMDDhhmm.md` file using the repository's `.agent-rules.md`.
3. Read `memorys/global.md` if it exists or use the path defined in `.agent-rules.md`.
4. Use the fixed defaults only when `.agent-rules.md` does not define another path.
5. scan `tasks/locks/` or project's lock files dir for your own lock using filename pattern: `<agent>_<taskid>.lock`
6. if your own lock exists:
   - inspect related task status in the resolved concrete tasklist file
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
15. After completing a task, the executor must commit all changed files. Follow the commit rules defined in `.agent-rules.md`.
16. update tasklist ,if had commit you must update hash to the tasklist 
17. remove lock 

## Locking Rules

- Hold only one active lock at a time.
- Never take over another agent's lock.
- Lock file naming is strictly `<agent>_<taskid>.lock` (e.g., `codex_t03160314.p010.lock`).
- If local rules and the current tasklist conflict, `.agent-rules.md` takes precedence for process/repo constraints, while `tasklist_rules.md` defines tasklist structures.
- If an AI already has an unfinished lock task, it must continue that task first.

## Allowed Tasklist Updates and File Modifications

Update only the tasklist fields allowed by `tasklist_rules.md`.
Do not modify the tasklist table structure unless requested.

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

## Backup a Done Tasklist
When a done tasklist is no longer needed directly by others, move it to the backup directory (e.g., `docs/backuptask/`) as defined in your local setup.


## Quick Reference

- Build tasklist: read rules -> create tasklist -> self-review -> register if required
- Execute task: read rules -> inspect locks -> claim -> implement -> verify -> self-review -> update tasklist -> unlock
- Missing bootstrap files: copy templates and create the default files/directories
- Existing own lock: resume before starting new work

## Common Mistakes

- Hardcoding absolute paths from one repository into the skill
- Updating tasklist columns that local rules did not authorize
- Claiming a task before checking dependencies or other-agent locks
- Marking `done` after implementation but before verification
- Ignoring repository-specific commit or reporting rules in `.agent-rules.md`

## Example Invocations

- `Use taskexec to run docs/backuptask/tasklist03201111.md`
- `Use taskexec to build tasklist, "Refactor checkout discount flow with tests first"`

## Bootstrapping A New Repository

When a repository wants to adopt this workflow but does not yet have local rule files:

1. Copy `assets/templates/.agent-rules.md` to the repository root.
2. Copy `assets/templates/tasklist_rules.md` to the repository root.
3. Create `tasklistall.md`, `memorys/global.md`, `tasks/locks/`, and `tasks/<agent>/` in the default paths.
4. Write the active default/custom paths into the repository's `.agent-rules.md`.
5. When the first tasklist is needed, create `tasklistMMDDhhmm.md`.
6. Only then start building or executing tasklists with this skill.
