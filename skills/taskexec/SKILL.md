---
name: taskexec
description: Use when creating or executing markdown tasklists in a repository that keeps `.agent-rules.md` and `tasklist_rules.md` at the root and stores taskexec runtime artifacts under the fixed per-subproject layout `taskexec/<subproject>/tasklistall.md`, `codex/`, `docs/backuptask/`, `docs/qa/`, `locks/`, `tasklog/`, and `details/`.
---

# Taskexec

## Overview

Execute tasklist-driven work in repositories that store process rules in markdown. Read the repository-root `.agent-rules.md` first, use `tasklist_rules.md` as the only tasklist schema source, then claim work safely, verify it, and persist each task status change with the required commit chain.

This skill supports the multi-subproject/worktree pattern where repository rule files stay at the root, while taskexec runtime artifacts are isolated per subproject under a fixed scope root such as `taskexec/windskills/`.

## Fixed Layout

Inside each `taskexec/<subproject>/` scope root, use only this layout:

- `tasklistall.md`
- `codex/tasklistMMDDhhmm.md` for active tasklists
- `docs/backuptask/tasklistMMDDhhmm.md` for archived tasklists
- `docs/qa/` for taskexec-generated verification reports
- `locks/`
- `tasklog/`
- `details/`

The directory name `codex/` is a fixed workflow directory name in this skill. It is not an ownership signal and does not mean only Codex may use it.

Do not place active tasklists at the scope-root top level. Do not invent another tasklist directory. Do not search the whole repository for tasklists as a fallback.

## When to Use

Use this skill when the repository manages work with files such as:

- repository-root `.agent-rules.md`
- repository-root `tasklist_rules.md`
- `taskexec/<subproject>/tasklistall.md`
- `taskexec/<subproject>/codex/`
- `taskexec/<subproject>/docs/backuptask/`
- `taskexec/<subproject>/docs/qa/`
- `taskexec/<subproject>/locks/`
- `taskexec/<subproject>/tasklog/`
- optionally `taskexec/<subproject>/details/`

Do not use this skill for direct ad-hoc coding requests that are not driven by a tasklist.

## Required Inputs

Read these files in order before taking action:

1. Repository-root `.agent-rules.md`
2. Repository-root `tasklist_rules.md`
3. Resolve the target taskexec scope root, for example `taskexec/windskills/`
4. The target tasklist file named by the user, but only if it is under `codex/` or `docs/backuptask/`; otherwise treat it as invalid
5. If no tasklist file was provided, resolve a concrete tasklist from the scope-local `tasklistall.md`
6. The target task `Detail` file when the `Detail` column is not empty
7. `memorys/global.md` if it exists or local rules require it
8. Project memory referenced by local rules, if it exists

Repository-local scope-root selection rules, commit message policy, task selection rules, and follow-up bugfix authority belong in the repository's own `.agent-rules.md`.

All task formatting rules such as `TaskID`, fixed columns, tasklist metadata, and executor-editable fields belong exclusively to `tasklist_rules.md`.

## Initialization

If the repository is being set up for taskexec for the first time:

- Copy `assets/templates/.agent-rules.md` and `assets/templates/tasklist_rules.md` to the repository root.
- Create one scope root per subproject, for example `taskexec/<subproject>/`.
- Inside that scope root, create `tasklistall.md`, `codex/`, `docs/backuptask/`, `docs/qa/`, `locks/`, `tasklog/`, and `details/`.
- Create `memorys/global.md` only when the repository keeps that path active.
- Write the active repository-root rule paths and scope-root selection rules into `.agent-rules.md`.
- Create the first `tasklistMMDDhhmm.md` inside `codex/` when the first tasklist is needed.

Example tasklist/template files:

- `assets/templates/tasklist03171111.md`
- `assets/templates/t03200058.p910.md`

For repository prerequisites and expected file layout, read `references/repo-contract.md`.

## Mode A: Build Tasklist

Use this mode when the user asks to create a new tasklist or append follow-up work to an active, non-archived tasklist.

1. Read repository-root `.agent-rules.md` and `tasklist_rules.md`.
2. Resolve the target scope root for the requested subproject or directory. Do not guess when multiple candidate scope roots exist.
3. Extract the exact tasklist schema, fixed columns, status rules, review requirements, and `TaskID` rules from `tasklist_rules.md`.
4. Prefix the overall task name with the tasklist creator marker required by local rules, for example `codex:`.
5. If a task needs more than 1-2 sentences, links, or a longer acceptance spec, create `details/d_<taskid>.md` inside the same scope root and place that path in the `Detail` column. If the task is short, leave `Detail` empty.
6. If a separate verification report is needed, write it under `docs/qa/` inside the same scope root.
7. For a same-workflow follow-up bugfix, add a new `bugfix` row to the same active tasklist instead of rewriting the completed row. Include `FIX:<source_taskid>` in the row `Description` or referenced `Detail`.
8. Only the tasklist creator may append follow-up tasks or create/edit their `Detail` files. If the creator is unavailable, stop and hand the decision back to a human.
9. Run the required self-review before claiming the tasklist is ready.
10. Create the tasklist under `codex/`.
11. Register the tasklist in the scope-local `tasklistall.md` with `Dir` set to `codex/`.
12. After registration, read that same `tasklistall.md` and run the repository's active-tasklist sweep rule only against `codex/` and `docs/backuptask/` inside the same scope root. Update the same `tasklistall.md` and commit the resulting change.
13. Commit the tasklist build/update with the repository's tasklist commit rule before moving on.

## Mode B: Execute Tasklist

Use this mode when the user asks to run tasks from an existing tasklist.

### Startup Sequence

1. Read repository-root `.agent-rules.md` and `tasklist_rules.md`, then resolve the target taskexec scope root before touching generated files.
2. If the user gave a tasklist path, it must be under `codex/` or `docs/backuptask/` inside the resolved scope root. Otherwise stop and report an invalid tasklist location.
3. If no tasklist file was provided, resolve it from the scope-local `tasklistall.md` using the repository's `.agent-rules.md`. Do not guess when multiple active tasklists or multiple candidate scope roots exist.
4. Read the task `Detail` file if the selected task row points to one.
5. Read `memorys/global.md` or the memory path defined in `.agent-rules.md`, when present.
6. Scan `locks/` inside the same scope root for your own `<agent>_<taskid>.lock`.
7. If your own unfinished lock exists, read `tasklog/<agent>_<taskid>.md` when it already exists, then resume that task before starting any new task.
8. If no active own lock exists, find the first matching `todo` task for your role and check dependencies.
9. Create the lock.
10. Claim the task.
11. Initialize `tasklog/<agent>_<taskid>.md` if it does not exist yet.
12. Commit the tasklist status change from `todo` to `doing`.
13. Execute the work.
14. Run required verification.
15. Perform self-review.
16. If refactor is needed, repeat execute -> verify -> self-review until no required refactor remains.

### Required Commit Chain

Persist task execution in this order:

1. Commit all task implementation files using the repository's task commit rule.
2. Record the real task commit hash in `tasklog/<agent>_<taskid>.md` and keep the `Detail` reference there when one exists.
3. Write the same hash, review result, and terminal task fields back to the tasklist row.
4. Commit the tasklist state update. This commit must include the tasklist file itself, and may also include the task log if the log changed after the task commit.
5. Remove the lock.

Every tasklist status change must be committed. That includes the initial `todo -> doing` claim commit, terminal row updates such as `done`, `blocked`, `partial`, `cancelled`, and any archive action.

If the user asks to archive/submit, or local rules require an archive sweep before creating the next tasklist, follow the repository's archive sweep rule after the tasklist state commit. Archive sweeps are scope-local and only touch `codex/` and `docs/backuptask/`.

## Locking Rules

- Hold only one active lock at a time.
- Never take over another agent's lock.
- Lock file naming is strictly `<agent>_<taskid>.lock`.
- Locks are scope-local. Never scan, create, or remove another subproject's lock while working in the current scope root.
- If local rules and the current tasklist conflict, `.agent-rules.md` controls repository process rules while `tasklist_rules.md` controls tasklist structure.
- If an AI already has an unfinished lock task, it must continue that task first.

## Allowed Tasklist Updates And File Modifications

Update only the tasklist fields allowed by `tasklist_rules.md`.
Do not modify the tasklist table structure unless explicitly asked to revise the process.

During normal task execution, only modify:

- the task log under `tasklog/<agent>_<taskid>.md`
- your own lock under `locks/<agent>_<taskid>.lock`
- executor-editable fields in the selected tasklist row
- verification reports under `docs/qa/` when the task requires them
- code/tests/docs/config directly required by the claimed task

Treat `details/d_<taskid>.md` as read-only during task execution unless the user explicitly asks to revise the task definition itself.

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

## Tasklist State And Follow-up

- Task row `done` belongs only to individual task rows.
- A task row that is already `done` must never be changed back to another status.
- A tasklist stays `active` in its scope-local `tasklistall.md` until it is archived.
- Active tasklists live only under `codex/`.
- Archived tasklists live only under `docs/backuptask/`.
- Follow-up bugfixes are tracked by appending new rows to the same active tasklist inside the same scope root.
- An `archived` tasklist does not accept new task rows.

## Quick Reference

- Build tasklist: read root rules -> resolve scope root -> create `details/` and `docs/qa/` files if needed -> create tasklist under `codex/` -> self-review -> register in scope-local `tasklistall.md` with `Dir=codex/` -> sweep `codex/`/`docs/backuptask/` -> commit
- Execute task: read root rules -> resolve scope root -> inspect `locks/` -> read detail doc -> claim -> commit `todo -> doing` -> implement -> verify -> write `docs/qa/` if needed -> self-review -> commit task files -> record real hash -> commit tasklist state -> unlock
- Follow-up bugfix: reuse the same active non-archived tasklist in `codex/` when scope still matches
- Missing bootstrap files: copy templates, create repository-root rules, then create the selected scope root and its fixed runtime directories
- Existing own lock: resume before starting new work

## Common Mistakes

- Hardcoding one repository's absolute paths into the skill
- Placing active tasklists directly under `taskexec/<subproject>/` instead of `codex/`
- Inventing another tasklist directory besides `codex/` and `docs/backuptask/`
- Searching the whole repository for tasklists instead of respecting the fixed layout
- Updating tasklist columns that local rules did not authorize
- Claiming a task before checking dependencies or other-agent locks
- Forgetting that `todo -> doing` also needs its own tasklist commit
- Rewriting a completed row instead of appending a new follow-up bugfix row
- Letting anyone other than the tasklist creator append follow-up tasks

## Example Invocations

- `Use taskexec to run taskexec/windskills/codex/tasklist04210212.md`
- `Use taskexec to append a follow-up bugfix to taskexec/shop-admin/codex/tasklist04230500.md`
- `Use taskexec to build tasklist for subproject likeshop-admin, "Refactor checkout discount flow with tests first"`

## Bootstrapping A New Repository

When a repository wants to adopt this workflow but does not yet have local rule files:

1. Copy `assets/templates/.agent-rules.md` to the repository root.
2. Copy `assets/templates/tasklist_rules.md` to the repository root.
3. Create the chosen scope root such as `taskexec/<subproject>/`.
4. Inside that scope root, create `tasklistall.md`, `codex/`, `docs/backuptask/`, `docs/qa/`, `locks/`, `tasklog/`, and `details/`.
5. Create `memorys/global.md` only if the repository wants a global memory file.
6. Write the active repository-root rule paths plus the scope-root selection rules into `.agent-rules.md`.
7. Create the first `tasklistMMDDhhmm.md` inside `codex/` when work begins.
8. Copy `scripts/new_issue.sh` and `scripts/gen_issues.sh` to the repository `/scripts/` dir if the repository wants the bundled issue workflow.
9. Only then start building or executing tasklists with this skill.
