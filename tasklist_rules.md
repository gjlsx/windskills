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

`tasklist_rules.md` is the single source of truth for required tasklist structure, fixed columns, status vocabulary, and `TaskID` format.

## Required Tasklist Structure

Each tasklist should include:
1. tasklist title 
2. overall task name
3. overall task description
4. generation time
5. tasklist status and inheritance source
6. participant roles
7. decomposed task table
8. tasklist self-review result

## Tasklist Naming

- file name format: `tasklistMMDDhhmm.md`
  tasklist example see: `assets/templates/tasklist03171111.md`
- when using `taskexec` to build a tasklist, the root agent should execute `git add <tasklist_file>` and `git commit -m "tasklist filename + overall task title/description"` upon self-review success.
- Claim task file example see: `assets/templates/t03200058.p910.md`

## Task Planning Rules

- Plan framework first, then details.
- Prefer modular decomposition.
- Use test-first thinking for each implementation task.
- Include at least one check for new hardcoded business values such as ratios, amounts, or thresholds.
- If a task introduces business parameters, specify the config key and validation path in the task description.

## Task Table

Keep this table structure unchanged unless the repository intentionally adopts another schema:

| Status | TaskID | Project | Title | Description | Type | Priority | Role | Owner | Depends | module | Claim | Finish | Report | Git | Review | Score |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| todo | t03231200.p001 | demo-project | Example title | Example description | feature | P1 | codex |  |  | backend |  |  |  |  |  |  |

## Field Rules

- `TaskID`: `tMMDDhhmm.pXXX`
- `Project`: repository or project name
- `Role`: target executor role
- `module`: area such as `frontend`, `backend`, `docs`, or other local module names
- `Depends`: comma-separated task IDs or empty
- `Claim`: `startat:YYMMDDHHMMSS <agent> tasks/tasklog/<agent>_<taskid>.md`
- `Finish`: `finishat:YYMMDDHHMMSS`
- `Review`: `pass:no-refactor-needed`, `pass:minor-refactor-done`, or `partial:needs-followup`
- `Score`: a score such as `91/100`
- `Git`: commit hash

## Status Meanings

- `todo`: not claimed
- `doing`: claimed and being worked on
- `blocked`: cannot proceed because of dependency or environment issue
- `partial`: partially completed with next steps documented
- `pending`: paused for external reasons
- `done`: completed with verification passed and self-review finished
- `cancelled`: no longer needed

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

## commit tasklist and add it to tasklistall.md
   1.after review ok before doing task, registering the tasklist in `tasklistall.md` according to the repository `.agent-rules.md`, append only the allowed entry.
   2.after review ok before doing task, must had a git commit change files done with msg include: `tasklist filename + overall task title/description`,
   after commit ok, could go to next step

## tasklistall.md is only a tasklist index file in the project.
`tasklistall.md` is only an index of all tasklist files in the project.
Its default paths, index format, and concrete tasklist resolution rules are defined in the repository `.agent-rules.md`.
