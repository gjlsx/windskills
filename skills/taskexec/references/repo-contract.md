# Repository Contract For `taskexec`

This skill is intentionally project-agnostic. It expects each target repository to define its own task execution contract in local files.

## Expected Repository Files

- `.agent-rules.md`
- `tasklist_rules.md`
- `tasklistall.md` or an explicit tasklist file supplied by the user
- `tasks/locks/`
- `tasks/<agent>/`

Optional but supported:

- `memorys/global.md`
- `memorys/<project>/memory.md`

## What Local Rules Should Define

At minimum, the repository should define:

- task selection rules
- lock ownership rules
- task claim format
- allowed tasklist columns for executor updates
- status vocabulary
- testing and self-review requirements
- definition of done
- commit requirements, if any

## Porting Notes

When adapting an existing project-specific task execution process into this skill:

1. Move repository-specific paths out of `SKILL.md`.
2. Keep repository-specific policy in local rule files.
3. Keep only reusable execution behavior in this skill.
4. Prefer relative repository-root paths in examples.

## Minimal Trigger Examples

This skill should trigger for prompts like:

- `Use taskexec to run docs/tasklist04121000.md`
- `Build a tasklist for the payment retry cleanup`
- `Execute the next codex task from tasklistall.md`
