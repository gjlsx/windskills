# Tasklist Rules

Scheduler creates and maintains the structure of the tasklist. Executor may update only:

- `Owner`
- `Status`
- `Claim`
- `Finish`
- `Report`
- `Git`
- `Review`
- `Score`

`tasklist_rules.md` is the single source of truth for required tasklist structure, fixed columns, task status vocabulary, and `TaskID` format.

## Required Tasklist Structure

Each tasklist should include:
1. tasklist title
2. overall task name
3. overall task description
4. generation time
5. tasklist status, creator, and inheritance source
6. participant roles  
   :example: -`codex`（bug修复/验证,`codex` is do the task's ai name）
            - `wind`（业务验收,here wind is human）
7. decomposed task table
8. tasklist self-review result

## Tasklist Naming

- file name format: `tasklistMMDDhhmm.md`
- overall task name should begin with `<creator>:` such as `codex: Bucket sort demo regression fix`
- section 5 should record `creator: <agent>`
- tasklist example: `assets/templates/tasklist03171111.md`
- task log example: `assets/templates/t03200058.p910.md`

## Task Planning Rules

- Plan framework first, then details.
- Prefer modular decomposition.
- Use test-first thinking for each implementation task.
- Include at least one check for new hardcoded business values such as ratios, amounts, or thresholds.
- If a task introduces business parameters, specify the config key and validation path in the task description.
- If a task needs more than 1-2 sentences, references, or detailed acceptance criteria, create `tasks/details/d_<taskid>.md` and place that path in the `Detail` column.
- If the task can be described clearly in 1-2 sentences, `Detail` may stay empty.
- `Detail` stores task requirement detail and long-form acceptance notes.
- Task logs store actual execution, verification, and finish evidence under `tasks/tasklog/<agent>_<taskid>.md`, and should reference the same `Detail` path when one exists.

## Follow-up Bugfix Planning Rule

- Same-workflow bugfixes should default to the current active, non-archived tasklist.
- A follow-up bugfix must be a new task row, not a rewrite of a completed row.
- A completed row never changes status again.
- Only the tasklist creator may append follow-up rows.
- If the creator is unavailable, stop and hand the decision back to a human.
- Follow-up bugfix rows should set `Type` to `bugfix`.
- Include `FIX:<source_taskid>` in the `Description` or in the referenced `Detail` document.
- Direct fix commits outside taskexec follow the repository `.agent-rules.md` issue rules; they are not encoded as `ISSUE-XXX` inside tasklist rows by default.

## Task Table

Keep this table structure unchanged unless the repository intentionally adopts another schema:

| Status | TaskID | Project | Title | Description | Detail | Type | Priority | Role | Owner | Depends | module | Claim | Finish | Report | Git | Review | Score |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| todo | t03231200.p001 | demo-project | Example title | Example description | tasks/details/d_t03231200.p001.md | feature | P1 | codex |  |  | backend |  |  |  |  |  |  |

## Field Rules

- `TaskID`: `tMMDDhhmm.pXXX`
- `Project`: repository or project name
- `Role`: target executor role
- `Detail`: optional task detail path such as `tasks/details/d_<taskid>.md`; leave empty when the short description is sufficient
- `module`: area such as `frontend`, `backend`, `docs`, or other local module names
- `Depends`: comma-separated task IDs or empty
- `Claim`: `startat:YYMMDDHHMMSS <agent> tasks/tasklog/<agent>_<taskid>.md`
- `Finish`: `finishat:YYMMDDHHMMSS`
- `Review`: `pass:no-refactor-needed`, `pass:minor-refactor-done`, or `partial:needs-followup`
- `Score`: a score such as `91/100`
- `Git`: the real task commit hash written back after the task commit is created

## Task Status Meanings

- `todo`: not claimed
- `doing`: claimed and being worked on
- `blocked`: cannot proceed because of dependency or environment issue
- `partial`: partially completed with next steps documented
- `pending`: paused for external reasons
- `done`: completed with verification passed and self-review finished
- `cancelled`: no longer needed

## Tasklist Status

Tasklist status is separate from task row status:

- `active`: tasklist is still live and may receive creator-approved follow-up rows
- `archived`: tasklist has been moved to backup and no longer accepts new rows

`done` belongs only to task rows. It is not a tasklist-level status in `tasklistall.md`.

## Tasklist Review

After the tasklist is created, the creator must perform a self-review.

The review should ensure:

- the tasklist reasonably covers the intended requirement
- task decomposition is executable
- there are no obvious dependency or ordering issues
- business numeric rules are configuration-first when required

Review result must be one of:

- `pass`
- `fail`

If review is `fail`, revise the tasklist and review again until it passes.

## Tasklist Commit Points

1. After review passes and before doing task execution, register the tasklist in `tasklistall.md` according to the repository `.agent-rules.md`.
2. Immediately after registration, read `tasklistall.md`, rescan all indexed `active` tasklists according to the repository `.agent-rules.md`, archive any tasklist whose rows are all `done`, update `tasklistall.md`, and commit the `tasklistall.md` change.
3. After initial registration and the active-tasklist sweep, create a tasklist build commit whose message includes `tasklist filename + overall task title/description`.
4. After changing a task row from `todo` to `doing`, commit the tasklist file.
5. After a task commit is created, write the real task commit hash back to the task log and tasklist row, then create one tasklist state commit. This commit must include the tasklist file itself, and may also include metadata files updated after the task commit.
6. When a follow-up row is added, commit the updated tasklist file.
7. After moving a tasklist into backup, read `tasklistall.md`, rescan all indexed `active` tasklists according to the repository `.agent-rules.md`, archive any tasklist whose rows are all `done`, update `tasklistall.md`, and create an archive commit that includes `tasklistall.md`.

## tasklistall.md Is Only A Tasklist Index

`tasklistall.md` is only an index of all tasklist files in the project.
Its default paths, index format, concrete tasklist resolution rules, and archive sweep rules are defined in the repository `.agent-rules.md`.
