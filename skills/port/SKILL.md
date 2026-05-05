---
name: port
description: Port a feature or fix from a PR in a sister project to the current project. Used when copying code between two similar codebases (e.g. two SaaS products that share patterns).
argument-hint: "<source PR URL> [<additional PR URL> ...]"
allowed-tools:
  - AskUserQuestion
  - Bash(git *)
  - Edit
  - Glob
  - Grep
  - Read
  - Write
  - mcp__github__pull_request_read
  - mcp__github__issue_read
  - mcp__github__get_file_contents

---

# Port

Port a feature or fix from a PR in a sister project (project B) into the current project (project A). The two projects have similar architectures, so the code should be ported as similarly as possible — preserve names, structure, and idioms unless project A's conventions force a change.

## Input

`$ARGUMENTS` is one or more GitHub PR URLs (or `<owner>/<repo>#<number>` short refs):

- The **first** PR is the source feature/fix.
- Any **additional** PRs are follow-up fixes that landed on top of the original. Treat them as part of the same logical change to port.

If `$ARGUMENTS` is empty, use `AskUserQuestion` to ask for the source PR URL.

## Steps

<read-source>

For each PR (the main one and each follow-up, in order):

1. Use `mcp__github__pull_request_read` (method: `get`) to fetch metadata (title, body, base/head SHAs, merge state).
2. Use `mcp__github__pull_request_read` (method: `get_files`) to list changed files.
3. Use `mcp__github__pull_request_read` (method: `get_diff`) to read the full diff.
4. If the PR body references issues (`Refs #N`, `Fixes #N`, `Closes #N`), read those with `mcp__github__issue_read` to capture the *intent* of the change.

Combine the diffs of all PRs into one logical changeset. If a follow-up PR reverts or modifies a hunk from the main PR, the **net** result is what gets ported — don't replay both.

</read-source>

<map-to-current-project>

The two projects are similar but not identical. For each file touched in project B:

1. Find the equivalent file in project A. Heuristics:
   - Same relative path is the most common case.
   - If not, search by the function/class names being changed.
   - If a file exists in B but not A (e.g. a brand-new module), it will be created in A.
2. Note any structural mismatches early (different folder layout, renamed modules, divergent helpers). Surface these to the user before editing if they require a judgment call.

</map-to-current-project>

<port-the-code>

Apply the combined changeset to project A. Guiding principles:

- **Preserve names and structure**: function names, variable names, class names, file names, ordering of imports and methods. The two codebases should look like siblings, not cousins.
- **Preserve commit-level intent**: if the source PR added a helper *and* called it from two places, do both.
- **Adapt only where required**: if project A already has a helper that project B is introducing, use the existing one.
- **Don't refactor unrelated code** while porting. Anything not in the source diff stays untouched.
- **Don't invent improvements**. If the source PR has a quirk or a TODO, port the quirk and the TODO. Improvements belong in a follow-up PR, not this port. Suggest them in the final report as open questions for the user to review.

Use `Read` before `Edit` on every file you touch. Use `Write` only for files that don't yet exist in project A.

</port-the-code>

<verify>

Run project A's standard checks (linters, type checks, unit tests).

</verify>

<diff-report>

After porting, produce a **Differences Report** comparing the ported code in project A against the source in project B. Cover, at minimum:

1. **Files that exist in one project but not the other** (and why).
2. **Renamed symbols** — function/class/variable names that had to change, with the reason.
3. **Adapted logic** — anywhere the implementation diverges from the source (e.g. used an existing helper, different ORM/model field, different error type), with one-line justification per divergence.
4. **Skipped changes** — anything from the source PR that was deliberately not ported, with the reason.
5. **Open questions** — judgment calls the user should review.

Format as a bulleted markdown report under a `## Differences` heading. Be specific: cite file paths and line numbers from project A. Keep each bullet to one or two sentences.

If there are **zero** differences, say so explicitly — that's a successful, fully faithful port.

Finally, if you identified any patterns or practices in the source PR that are missing in project A, note those as potential improvements to make in a follow-up PR after the port is complete.

</diff-report>

<commit>

Commit the ported changes on the current branch. Do **not** push, and do **not** open a PR — the user will review and push when ready.

Before committing:

- Confirm `git status` is clean of unrelated changes. If there are unrelated modified files, stop and ask the user how to proceed.
- Stage only files that are part of this port. Prefer `git add <path>` over `git add -A`.

**Commit message**:

- **Title**: same as the source PR's title.
- **Body**: start from the source (main) PR's body verbatim. Then:
  - Keep any `Refs #N` / `Fixes #N` / `Closes #N` lines from the source PR **as-is** — these reference issues in project B and stay pointing there.
  - Append a `Port of <full URL of the main source PR>` line.
  - If there are follow-up PRs being ported alongside, append an `Also,` section with one bullet per follow-up summarizing what it added or changed:

    ```
    Also,
    * <one-line summary of follow-up PR 2> (<full URL>)
    * <one-line summary of follow-up PR 3> (<full URL>)
    ```

Use full GitHub URLs (not `#N`) for the `Port of` and `Also` lines, since `#N` would resolve to issues in project A's repo, not project B's.

Pass the message via a HEREDOC to preserve formatting:

```
git commit -m "$(cat <<'EOF'
<title>

<body>
EOF
)"
```

</commit>

<output>

End the turn with:

1. A one-sentence summary of what was ported and the commit SHA.
2. The Differences Report.
3. Any suggested improvements or follow-up work identified during the port.
4. A reminder that the commit has **not** been pushed — the user reviews and pushes.

</output>
