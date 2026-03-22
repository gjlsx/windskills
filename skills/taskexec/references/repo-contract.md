# Repository Contract For `taskexec`

This skill is intentionally project-agnostic. It expects each target repository to define its own task execution contract in local files.

## Expected Repository Files

- `.agent-rules.md`
- `tasklist_rules.md`
- `tasklistall.md` as the default tasklist index, or an explicit tasklist file supplied by the user
- `tasks/locks/`
- `tasks/tasklog/`
- `tasks/details/` when the repository uses long-form task detail docs

Optional but supported:

- `memorys/global.md`
- `memorys/<project>/memory.md`

If these files do not exist on first run, bootstrap them from the bundled templates and create the default directories/files in the repository.

## What Local Rules Should Define

At minimum, the repository should define:

- task selection rules
- lock ownership rules
- default path layout if it does not use the standard defaults
- task claim format
- allowed tasklist columns for executor updates
- tasklist index status policy
- archive sweep rules
- active-tasklist rescan rules after registration/archive
- follow-up bugfix authority rules
- testing and self-review requirements
- definition of done
- commit requirements, including claim-status commits and tasklist state commits

## Porting Notes

When adapting an existing project-specific task execution process into this skill:

1. Move repository-specific paths out of `SKILL.md`.
2. Keep repository-specific policy in local rule files, and write default/custom paths into `.agent-rules.md`.
3. Keep only reusable execution behavior in this skill.
4. Prefer relative repository-root paths in examples.
5. Decide whether task detail docs under `tasks/details/` are mandatory or optional in that repository.

## Minimal Trigger Examples

This skill should trigger for prompts like:

- `Use taskexec to run tasklist04121000.md`
- `Build a tasklist for the payment retry cleanup`
- `Execute the next codex task from tasklistall.md`
- `Append a follow-up bugfix to the current tasklist`
