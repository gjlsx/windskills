# ISSUE-003
IssueID: ISSUE-003
Priority: [P0]
Status: RESOLVED
Summary: 前台未配置公众号时 JSSDK 初始化报错，已改为静默跳过
DetailFile: docs/issues/ISSUE-003.md

## Background
- This issue tracked the front-end JSSDK initialization error when the public account / WeChat login configuration was missing.
- The expected behavior was to skip initialization quietly instead of raising a blocking error toast.

## Resolution
- Backend JSSDK config handling was changed to return a success-shaped empty config when the public account config is missing.
- Front-end verification was changed to resolve `skip` instead of rejecting when configuration is missing or unavailable.
- The homepage and front-end initialization flow no longer surface the previous blocking error toast in the missing-config scenario.

## Evidence
- `taskexec/windskills/details/d_t03200058.p910.md`
- `skills/taskexec/assets/templates/t03200058.p910.md`
- `taskexec/windskills/docs/issue_index.md`
