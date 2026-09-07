---
name: changelog
description: Generate a weekly changelog entry and prepend it to documentation/changelog.md
argument-hint: "<YYYY-MM-DD Monday date, e.g. 2025-03-03>"
allowed-tools:
  - AskUserQuestion
  - Bash(gh issue comment*)
  - Bash(gh issue list*)
  - Bash(gh issue view*)
  - Bash(gh pr list*)
  - Bash(gh pr view*)
  - Bash(git *)
  - Edit
  - Glob
  - Grep
  - Read
  - Skill(demo-video-watcher)

---

Generate a changelog entry for a specific week and prepend it to `documentation/changelog.md`.

## Input

`$ARGUMENTS` should be a Monday date in `YYYY-MM-DD` format (e.g. `2025-03-03`). If empty, default to the most recent past Monday.

## Steps

1. **Parse the date**: Determine the Monday date from `$ARGUMENTS` or calculate the previous Monday.
2. **Confirm with user**: Show the target week (Monday to Sunday) and ask the user to confirm before proceeding.
3. **Resolve the Monday Meeting issue**: Some projects track the week in a Monday Meeting issue that lives in a separate ops repo. The project declares that repo in its own `CLAUDE.md`, on a line of this shape:

   ```markdown
   Monday Meeting issues live in `<owner>/<repo>`.
   ```

   Grep `CLAUDE.md` for `Monday Meeting issues live in` and take the repo from the matched line. If there is no such line, the project has no Monday Meeting — skip this step, the meeting context in step 9 and step 12 entirely, without a message or a question to the user.

   With the repo in hand, find the current meeting issue:

   ```
   gh issue list --repo <owner>/<repo> --state open --search "Monday Meeting in:title" --json number,title,createdAt
   ```

   Take the newest by `createdAt`. Exactly one such issue is open at a time, so this normally returns a single row. Never a closed issue, and never a number carried over from an earlier run or picked up from elsewhere in the conversation — resolve it here or not at all. An empty list skips the same three places as a missing declaration.

   Then read it, along with its comments, which carry the week's meeting notes and transcript:

   ```
   gh issue view <N> --repo <owner>/<repo> --comments
   ```
4. **Get commits**: Run `git log` for commits between that Monday 12:00 UTC and the following Monday 12:00 UTC:
   ```
   git log --oneline --format="%H %s" --after="<monday>T12:00:00Z" --before="<next-monday>T12:00:00Z" origin/main
   ```
5. **Filter commits**: Keep only commits with `feat:` or `fix:` prefixes. Discard `chore:` and everything else.
6. **Match commits to PRs**: For each commit, extract the PR number from `(#N)` in the commit message. If not found, run `gh pr list --search "<sha>" --state merged --json number,title` to find the PR.
7. **Read PRs and linked issues**: For each PR:
   - Run `gh pr view <N> --comments` to read the PR body and comments
   - Extract `Refs #N` references to find linked issues
   - Run `gh issue view <N> --comments` to read linked issues and their comments
8. **Watch demo videos**: If any issue or PR comments contain video attachments, invoke the `/demo-video-watcher` skill on them to understand what the feature does.
9. **Generate the entry**: Create a markdown entry in this format:

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
- Let the Monday Meeting issue from step 3 inform how the team talks about the week, but take every fact from the commits and PRs. Meeting notes cover plans and discussion as well as what shipped, so nothing enters the entry on their word alone.

10. **Insert the entry**: Use the Edit tool to insert the generated entry immediately after the `<!-- changelog-insert-marker -->` line in `documentation/changelog.md`.
11. **Show the result**: Display the generated entry to the user for review. Do not commit — let the user decide.
12. **Post to the Monday Meeting issue**: Ask the user whether to post the entry as a comment on the issue from step 3. On yes, post it verbatim, exactly as inserted into `documentation/changelog.md`:

    ```
    gh issue comment <N> --repo <owner>/<repo> --body-file - <<'EOF'
    <entry>
    EOF
    ```
