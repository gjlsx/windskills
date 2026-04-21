---
name: taskexec
description: Use when creating or executing markdown tasklists in a repository that tracks work with local agent rules, task logs, detail docs, active/archive tasklist states, and commit-backed status updates.
---

# Taskexec

## Overview

Execute tasklist-driven work in repositories that store process rules in markdown. Read the repository `.agent-rules.md` first, use `tasklist_rules.md` as the only tasklist schema source, then claim work safely, verify it, and persist each task status change with the required commit chain.

## When to Use

Use this skill when the repository manages work with files such as:

- `.agent-rules.md`
- `tasklist_rules.md`
- `tasklistall.md`
- `tasks/locks/`
- `tasks/tasklog/`
- optionally `tasks/details/`

Do not use this skill for direct ad-hoc coding requests that are not driven by a tasklist.

## Required Inputs

Read these files in order before taking action:

1. Repository-root `.agent-rules.md`
2. Repository-root `tasklist_rules.md`
3. The target tasklist file named by the user, or a concrete tasklist resolved from `tasklistall.md`
4. The target task `Detail` file when the `Detail` column is not empty
5. `memorys/global.md` if it exists or local rules require it
6. Project memory referenced by local rules, if it exists

Repository-local path layout, archive sweep rules, commit message policy, tasklist index policy, and follow-up bugfix authority belong in the repository's own `.agent-rules.md`.

All task formatting rules such as `TaskID`, fixed columns, tasklist metadata, and executor-editable fields belong exclusively to `tasklist_rules.md`.

**Initialization**: If the repository is being set up for taskexec for the first time, bootstrap it:

- Copy `assets/templates/.agent-rules.md` and `assets/templates/tasklist_rules.md` to the repository root.
- Create `tasklistall.md`, `tasks/locks/`, `tasks/tasklog/`, and `tasks/details/` in the default paths.
- Create `memorys/global.md` only when the repository keeps that path active.
- Write the active default/custom paths into the repository's `.agent-rules.md`.
- Create the first `tasklistMMDDhhmm.md` when the first tasklist is needed.

Example tasklist/template files:

- `assets/templates/tasklist03171111.md`
- `assets/templates/t03200058.p910.md`

For repository prerequisites and expected file layout, read `references/repo-contract.md`.

## Mode A: Build Tasklist

Use this mode when the user asks to create a new tasklist or append follow-up work to an active, non-archived tasklist.

1. Read `.agent-rules.md` and `tasklist_rules.md`.
2. Extract the exact tasklist schema, fixed columns, status rules, review requirements, and `TaskID` rules from `tasklist_rules.md`.
3. Prefix the overall task name with the tasklist creator marker required by local rules, for example `codex:`.
4. If a task needs more than 1-2 sentences, links, or a longer acceptance spec, create `tasks/details/d_<taskid>.md` and place that path in the `Detail` column. If the task is short, leave `Detail` empty.
5. For a same-workflow follow-up bugfix, add a new `bugfix` row to the same active tasklist instead of rewriting the completed row. Include `FIX:<source_taskid>` in the row `Description` or referenced `Detail`.
6. Only the tasklist creator may append follow-up tasks or create/edit their `Detail` files. If the creator is unavailable, stop and hand the decision back to a human.
7. Run the required self-review before claiming the tasklist is ready.
8. Register the tasklist in `tasklistall.md` as an index entry.
9. After registration, read `tasklistall.md` and run the repository's active-tasklist sweep rule. Resolve every indexed `active` tasklist from the repository root tasklist dir and configured tasklist dirs, archive any tasklist whose rows are all `done`, update `tasklistall.md`, and commit the resulting `tasklistall.md` change.
10. Commit the tasklist build/update with the repository's tasklist commit rule before moving on.

## Mode B: Execute Tasklist

Use this mode when the user asks to run tasks from an existing tasklist.

### Startup Sequence

1. Read required rule files: `.agent-rules.md`, `tasklist_rules.md`, and the target tasklist.
2. If no tasklist file was provided, resolve it from `tasklistall.md` using the repository's `.agent-rules.md`. Do not guess when multiple active tasklists exist.
3. Read the task `Detail` file if the selected task row points to one.
4. Read `memorys/global.md` or the memory path defined in `.agent-rules.md`, when present.
5. Scan `tasks/locks/` or the configured lock dir for your own `<agent>_<taskid>.lock`.
6. If your own unfinished lock exists, read `tasks/tasklog/<agent>_<taskid>.md` when it already exists, then resume that task before starting any new task.
7. If no active own lock exists, find the first matching `todo` task for your role and check dependencies.
8. Create the lock.
9. Claim the task.
10. Initialize `tasks/tasklog/<agent>_<taskid>.md` if it does not exist yet.
11. Commit the tasklist status change from `todo` to `doing`.
12. Execute the work.
13. Run required verification.
14. Perform self-review.
15. If refactor is needed, repeat execute -> verify -> self-review until no required refactor remains.

### Required Commit Chain

Persist task execution in this order:

1. Commit all task implementation files using the repository's task commit rule.
2. Record the real task commit hash in `tasks/tasklog/<agent>_<taskid>.md` and keep the `Detail` reference there when one exists.
3. Write the same hash, review result, and terminal task fields back to the tasklist row.
4. Commit the tasklist state update. This commit must include the tasklist file itself, and may also include the task log if the log changed after the task commit.
5. Remove the lock.

Every tasklist status change must be committed. That includes the initial `todo -> doing` claim commit, terminal row updates such as `done`, `blocked`, `partial`, `cancelled`, and any archive action.

If the user asks to archive/submit, or local rules require an archive sweep before creating the next tasklist, follow the repository's archive sweep rule after the tasklist state commit. After archiving any tasklist, read `tasklistall.md`, rescan all indexed `active` tasklists, synchronize any newly archivable tasklists into backup, update `tasklistall.md`, and commit the `tasklistall.md` change.

## Locking Rules

- Hold only one active lock at a time.
- Never take over another agent's lock.
- Lock file naming is strictly `<agent>_<taskid>.lock`.
- If local rules and the current tasklist conflict, `.agent-rules.md` controls repository process rules while `tasklist_rules.md` controls tasklist structure.
- If an AI already has an unfinished lock task, it must continue that task first.

## Allowed Tasklist Updates And File Modifications

Update only the tasklist fields allowed by `tasklist_rules.md`.
Do not modify the tasklist table structure unless explicitly asked to revise the process.

During normal task execution, only modify:

- the task log under `tasks/tasklog/<agent>_<taskid>.md`
- your own lock under `tasks/locks/<agent>_<taskid>.lock`
- executor-editable fields in the selected tasklist row
- code/tests/docs/config directly required by the claimed task

Treat `tasks/details/d_<taskid>.md` as read-only during task execution unless the user explicitly asks to revise the task definition itself.

## Verification Rules


- Never mark `done` unless required tests pass.
- If no tests exist, add minimal validation or record clear manual evidence.
- If a task affects any browser-visible page, entry, menu, button, form, redirect, list, detail view, or browser-executed workflow, browser validation is mandatory before `done`.
- For browser-required tasks, direct URL access alone does not count when the task claims a new entry/menu/button; verify from the claimed entry point.
- For browser-required tasks, route response, page title, redirect-to-login, `vite build`, unit tests, helper tests, and file existence checks are supporting evidence only; they do not by themselves justify `done`.
- For browser submit/workflow tasks, verify both:
  - the front-end action succeeds in the browser under the required runtime state
  - the result is visible in a downstream surface such as the next page, admin/backoffice, list/status change, network response, or database evidence
- If a browser task cannot be fully verified because of missing account, missing data, env mismatch, or runtime mismatch, mark it `partial` or `blocked`, record the gap explicitly, and continue. Do not mark it `done`.
- Self-review must explicitly check:
  - requirement satisfied
  - tests passed
  - no obvious duplicate logic left unhandled
  - naming consistent
  - no required refactor remains
  - task log complete
- For browser-required tasks, self-review must also explicitly check:
  - exact URL(s) tested
  - account or runtime state used, if any
  - whether verification was route-check, entry-check, or full flow-check
  - what exact downstream result was observed
- Task is `done` only if all are true:
  - implementation complete
  - tests passed
  - self-review passed
  - task log written
  - tasklist updated
  - lock removed
  - if browser-required: runtime/browser evidence recorded and matched the claimed result

### Browser Evidence Format

When browser validation is required, add a `Browser Evidence` section to the task log.

Use this structure:
- Environment:
  - base URL(s)
  - build/dev mode
- Account:
  - username, role, or runtime state used
- Entry Path:
  - where the flow started
  - whether direct URL was used, and why
- Action:
  - exact clicks/submissions performed
- Expected:
  - specific browser result and downstream result required by the task
- Observed:
  - exact browser result and downstream result actually observed
- Result:
  - `pass`
  - `partial`
  - `fail`

### Runtime Dependency Rule

- If task B depends on task A and task A is a browser page/flow task, task B may not treat A as fully accepted unless A has runtime/browser evidence.
- If task A only has code/test evidence but no runtime/browser evidence, task B must treat A as `code-landed-not-runtime-accepted`.
- Downstream closure/review/regression tasks must re-check the real runtime state instead of inheriting optimistic conclusions from upstream logs.

## Tasklist State And Follow-up

- Task row `done` belongs only to individual task rows.
- A task row that is already `done` must never be changed back to another status.
- A tasklist stays `active` in `tasklistall.md` until it is archived.
- Follow-up bugfixes are tracked by appending new rows to the same active tasklist.
- An `archived` tasklist does not accept new task rows.

## Quick Reference

- Build tasklist: read rules -> create tasklist -> add detail docs if needed -> self-review -> register -> sweep indexed active tasklists -> commit tasklist/tasklistall
- Execute task: read rules -> inspect locks -> read detail doc -> claim -> commit `todo -> doing` -> implement -> verify -> self-review -> commit task files -> record real hash -> commit tasklist state -> unlock
- Follow-up bugfix: reuse the same active non-archived tasklist when scope still matches
- Missing bootstrap files: copy templates and create the default files/directories
- Existing own lock: resume before starting new work

## Common Mistakes

- Hardcoding one repository's absolute paths into the skill
- Updating tasklist columns that local rules did not authorize
- Claiming a task before checking dependencies or other-agent locks
- Forgetting that `todo -> doing` also needs its own tasklist commit
- Rewriting a completed row instead of appending a new follow-up bugfix row
- Letting anyone other than the tasklist creator append follow-up tasks

## Example Invocations

- `Use taskexec to run tasklist03230500.md`
- `Use taskexec to append a follow-up bugfix to tasklist03230500.md`
- `Use taskexec to build tasklist, "Refactor checkout discount flow with tests first"`

## Bootstrapping A New Repository

When a repository wants to adopt this workflow but does not yet have local rule files:

1. Copy `assets/templates/.agent-rules.md` to the repository root.
2. Copy `assets/templates/tasklist_rules.md` to the repository root.
3. Create `tasklistall.md`, `tasks/locks/`, `tasks/tasklog/`, and `tasks/details/` in the default paths.
4. Create `memorys/global.md` only if the repository wants a global memory file.
5. Write the active default/custom paths into the repository's `.agent-rules.md`.
6. Create the first `tasklistMMDDhhmm.md` when work begins.
7. Copy `scripts/new_issue.sh` and `scripts/gen_issues.sh` to the repository `/scripts/` dir.
8. Only then start building or executing tasklists with this skill.
