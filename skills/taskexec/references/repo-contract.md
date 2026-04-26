# Repository Contract For `taskexec`

This skill is intentionally project-agnostic. It expects each target repository to define its own task execution contract in local files.

## Expected Repository Files

Repository root:

- `.agent-rules.md`
- `tasklist_rules.md`

Per-subproject taskexec scope root, for example `taskexec/<subproject>/`:

- `tasklistall.md`
- `codex/` for active tasklists
- `docs/backuptask/` for archived tasklists
- `docs/qa/` for taskexec-generated verification reports
- `locks/`
- `tasklog/`
- `details/` when the repository uses long-form task detail docs

Optional but supported:

- `memorys/global.md`
- `memorys/<project>/memory.md`

If these files do not exist on first run, bootstrap the rule files at the repository root and create the fixed runtime directories/files inside the chosen `taskexec/<subproject>/` scope root.

## What Local Rules Should Define

At minimum, the repository should define:

- how to resolve the target taskexec scope root for a subproject or directory
- task selection rules
- lock ownership rules
- task claim format
- allowed tasklist columns for executor updates
- tasklist index status policy
- follow-up bugfix authority rules
- testing and self-review requirements
- definition of done
- commit requirements, including claim-status commits and tasklist state commits

Local rules should not redefine the fixed taskexec subdirectories inside the scope root. This skill assumes:

- active tasklists only under `codex/`
- archived tasklists only under `docs/backuptask/`
- taskexec-generated verification reports under `docs/qa/`
- task logs under `tasklog/`
- detail docs under `details/`
- locks under `locks/`
- tasklist index at `tasklistall.md`
- taskexec path fields recorded as scope-relative paths

## Porting Notes

When adapting an existing project-specific task execution process into this skill:

1. Keep repository rule files at the repository root.
2. Move generated taskexec artifacts into a subproject scope root such as `taskexec/<subproject>/` to avoid cross-worktree merge conflicts.
3. Keep repository-specific policy in local rule files, but do not loosen the fixed taskexec subdirectory layout.
4. Prefer scope-relative examples inside scoped taskexec files.
5. Keep all taskexec-generated markdown, process files, and verification reports inside the selected scope root.
6. Decide whether task detail docs under `details/` are mandatory or optional in that repository.

## Minimal Trigger Examples

This skill should trigger for prompts like:

- `Use taskexec to run taskexec/windskills/codex/tasklist04121000.md`
- `Build a tasklist for the payment retry cleanup in subproject checkout-admin`
- `Execute the next codex task from taskexec/likeshop-admin/tasklistall.md`
- `Append a follow-up bugfix to the current tasklist in taskexec/mobile-store/codex/`
