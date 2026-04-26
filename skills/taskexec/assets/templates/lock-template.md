# Lock File Template

Filename format:
`<agent>_<taskid>.lock`

Examples:
- `codex_t03231200.p001.lock`
- `claude_t03231200.p002.lock`

Content template:

```yaml
agent: codex
task: t03231200.p001
owner: Codex
project: demo-project
created_at: 260316185749
updated_at: 260316185749
status: doing
log: tasklog/codex_t03231200.p001.md
```

Rules:
- each agent may have only one active lock
- scan your own lock before claiming a new task
- if task is already done/cancelled, remove your lock
- if task is unfinished, resume it directly
- no takeover by other AI
