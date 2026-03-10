---
name: changelog
description: Generate a weekly changelog entry and prepend it to documentation/changelog.md
argument-hint: "<YYYY-MM-DD Monday date, e.g. 2025-03-03>"
allowed-tools:
  - AskUserQuestion
  - Bash(git *)
  - Edit
  - Glob
  - Grep
  - Read
  - Skill(demo-video-watcher)
  - mcp__github__issue_read
  - mcp__github__list_commits
  - mcp__github__pull_request_read
  - mcp__github__search_pull_requests

---

Generate a changelog entry for a specific week and prepend it to `documentation/changelog.md`.

## Input

`$ARGUMENTS` should be a Monday date in `YYYY-MM-DD` format (e.g. `2025-03-03`). If empty, default to the most recent past Monday.

## Steps

1. **Parse the date**: Determine the Monday date from `$ARGUMENTS` or calculate the previous Monday.
2. **Confirm with user**: Show the target week (Monday to Sunday) and ask the user to confirm before proceeding.
3. **Get commits**: Run `git log` for commits between that Monday 12:00 UTC and the following Monday 12:00 UTC:
   ```
   git log --oneline --format="%H %s" --after="<monday>T12:00:00Z" --before="<next-monday>T12:00:00Z" origin/main
   ```
4. **Filter commits**: Keep only commits with `feat:` or `fix:` prefixes. Discard `chore:` and everything else.
5. **Match commits to PRs**: For each commit, extract the PR number from `(#N)` in the commit message. If not found, use the GitHub MCP `search_pull_requests` tool to find the PR.
6. **Read PRs and linked issues**: For each PR:
   - Use GitHub MCP `pull_request_read` to read the PR body and comments
   - Extract `Refs #N` references to find linked issues
   - Use GitHub MCP `issue_read` to read linked issues and their comments
7. **Watch demo videos**: If any issue or PR comments contain video attachments, invoke the `/demo-video-watcher` skill on them to understand what the feature does.
8. **Generate the entry**: Create a markdown entry in this format:

```markdown
## Week of <DD Mon YYYY>

### Features
- **Short title** -- User-facing description.

### Fixes
- **Short title** -- User-facing description.

---
```

Guidelines for writing entries:
- Write from a user's perspective — what changed for them, not implementation details
- Keep descriptions to one sentence
- NEVER link to GitHub issues or PRs — the changelog is user-facing documentation, not a developer log
- Omit the `### Features` or `### Fixes` section if there are none that week
- Sort entries alphabetically by title within each section
- If a commit included an update to /documentation, link to the updated documentation page.

9. **Insert the entry**: Use the Edit tool to insert the generated entry immediately after the `<!-- changelog-insert-marker -->` line in `documentation/changelog.md`.
10. **Show the result**: Display the generated entry to the user for review. Do not commit — let the user decide.
