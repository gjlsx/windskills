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

## Required Tasklist Structure

Each tasklist should include:

1. tasklist file name
2. overall task name
3. overall task description
4. generation time
5. tasklist status and inheritance source
6. participant roles
7. decomposed task table
8. tasklist self-review result

## Tasklist Naming

- file name format: `tasklistMMDDhhmm.md`

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
| todo | t03230001.p001 | demo-project | Example title | Example description | feature | P1 | codex |  |  | backend |  |  |  |  |  |  |

## Field Rules

- `TaskID`: `tMMDDhhmm.pXXX`
- `Project`: repository or project name
- `Role`: target executor role
- `module`: area such as `frontend`, `backend`, `docs`, or other local module names
- `Depends`: comma-separated task IDs or empty
- `Claim`: `startat:YYMMDDHHMMSS <agent> tasks/<agent>/<taskid>.md`
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
