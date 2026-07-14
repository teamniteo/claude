---
name: updater
description: Analyzes Renovate PRs to find changelogs, assess codebase impact, and post a summary comment to the PR. Used when asked to review or analyze a Renovate PR.
argument-hint: "<owner>/<repo>#<PR number> or GitHub PR URL"
allowed-tools:
  - AskUserQuestion
  - Bash(cat *)
  - Bash(gh api*)
  - Bash(gh pr comment*)
  - Bash(gh pr diff*)
  - Bash(gh pr view*)
  - Bash(git diff*)
  - Bash(git log*)
  - Bash(git remote*)
  - Bash(grep *)
  - Bash(head *)
  - Bash(python3 *)
  - Glob
  - Grep
  - Read
  - WebFetch
  - WebSearch
  - Write

---

# Renovate PR Updater

Find changelogs for each updated package, check codebase impact, and print a summary for the PR.

Be concise. No filler, no preamble, no narration of what you are doing. Go straight to running the parser scripts and fetching changelogs. Only output the final formatted comment.

<parse-input>

Parse `$ARGUMENTS` to extract `owner`, `repo`, and PR `number`. Accept:

- Full URL: `https://github.com/<owner>/<repo>/pull/<number>`
- Short ref: `<owner>/<repo>#<number>`
- Number only: `<number>` — infer owner/repo from `git remote get-url origin`

If `$ARGUMENTS` is empty or unparseable, use `AskUserQuestion` to ask for the PR URL or number.

</parse-input>

<read-pr>

Use `gh` for all GitHub reads. Pass `--repo <owner>/<repo>` explicitly so the commands work regardless of the current directory.

Fetch PR metadata:

```bash
gh pr view <number> --repo <owner>/<repo> --json title,body,state,url
```

List changed files and classify the ecosystem:

```bash
gh pr view <number> --repo <owner>/<repo> --json files --jq '.files[].path'
```

| Files changed | Ecosystem |
|---|---|
| `uv.lock` | Python / uv |
| `flake.lock` | Nix flakes |
| `package-lock.json`, `yarn.lock`, `bun.lock` | Node.js |

A single PR may touch multiple ecosystems. Handle each.

</read-pr>

<extract-versions>

Get the PR diff and pipe it straight into the appropriate parser. `gh pr diff` streams the raw unified diff to stdout, so no temp files or `jq` extraction are needed. Each parser in `~/.claude/skills/updater/utils/` reads raw diff text from stdin and outputs `package old_version new_version` per line.

**Python / uv** (`uv.lock`):
```bash
gh pr diff <number> --repo <owner>/<repo> | python3 ~/.claude/skills/updater/utils/parse_uv_diff.py
```

**Nix flakes** (`flake.lock`):
```bash
gh pr diff <number> --repo <owner>/<repo> | python3 ~/.claude/skills/updater/utils/parse_flake_diff.py
```

**Node.js** (`package-lock.json` / `yarn.lock` / `bun.lock`):
```bash
gh pr diff <number> --repo <owner>/<repo> | python3 ~/.claude/skills/updater/utils/parse_npm_diff.py
```

Then identify **direct dependencies** by reading the manifest file:
- Python: `pyproject.toml` — `[project.dependencies]`, `[dependency-groups]`
- Node.js: `package.json` — `dependencies`, `devDependencies`
- Nix: `flake.nix` — all inputs in the `inputs` attrset are direct. Nested inputs (dependencies of inputs) are transitive.

Only fetch changelogs for direct dependencies. Count transitive updates separately for the summary.

</extract-versions>

<fetch-changelogs>

For each **direct** dependency update, find the changelog. Try in order:

1. **PR body**: Renovate often includes release notes and changelogs directly in the PR description (especially for GitHub Actions). Check the PR body first. If it already contains changelog entries for a package, use those instead of fetching externally.

2. **GitHub Releases**: Find the package's GitHub repo, then use `WebFetch` to read releases between old and new versions.
   - Python: `https://pypi.org/pypi/<package>/json` → `info.project_urls`
   - Node.js: `https://registry.npmjs.org/<package>` → `repository.url`
   - Nix (`nixpkgs`): Don't just say "routine update". Do this:
     1. Read `flake.nix` to find which packages are used (e.g., `pkgs.python313`, `pkgs.nodejs`, `pkgs.postgresql`)
     2. For each used package, `WebSearch` for `"nixpkgs <package> update"` or check the NixOS discourse/release notes for notable changes
     3. Report on specific package updates that affect this project
     4. If no notable changes to used packages, say "No changes to packages used in this project" (and list what packages are used)
   - Nix (other flake inputs): use the compare URL to `WebFetch` the GitHub comparison page and summarize actual changes. Don't just paste a link.

3. **CHANGELOG file**: Read `CHANGELOG.md`, `CHANGES.md`, or `HISTORY.md` from the package repo with:
   ```bash
   gh api repos/<owner>/<repo>/contents/<file> -H "Accept: application/vnd.github.raw"
   ```

4. **Web search**: `WebSearch` for `"<package> changelog <new_version>"`.

5. **Skip gracefully**: Note "No changelog found" and move on.

**CRITICAL: Only report changes BETWEEN the old and new versions.** If updating from 23.0.0 → 25.0.0, only include entries for 23.0.1 through 25.0.0. A CVE patched in 22.0.0 is irrelevant when updating from 23.0.0. Verify every CVE or breaking change is actually in the version range. If you cannot confirm the version, do not mention it.

Look for and tag with:
- `[Breaking]` — removed APIs, deprecated features, breaking behavior changes
- `[Security]` — CVEs, vulnerability fixes
- `[Feature]` — new capabilities, improvements
- `[Fix]` — bug fixes relevant to the codebase

**Only include changelog entries that are relevant to this codebase.** Don't list every change — focus on what actually matters for this project.

</fetch-changelogs>

<read-codebase>

Use ultrathink. Familiarize yourself with the codebase.

</read-codebase>

<assess-impact>

For each direct dependency with changelog findings:

1. Search the local codebase for usage:
   - Python: `Grep` for `import <pkg>` or `from <pkg>`
   - Node.js: `Grep` for `require('<pkg>')`, `from '<pkg>'`, `import.*from '<pkg>'`

2. Cross-reference changelog entries with actual codebase usage:
   - For breaking changes: check if the removed/deprecated features are used
   - For new features: check if they could benefit existing code patterns
   - For security fixes: note if the vulnerable code path is used

3. In the output:
   - **Changelog highlights**: list changes that impact this codebase
   - **Codebase impact**: explain *how* it impacts (e.g., "uses deprecated `foo()` in `bar.py:42`" or "new `batch_process()` could replace manual loop in `handler.py`")

4. If the codebase is not checked out locally, skip and note it.

</assess-impact>

<output>

Write the formatted comment to a temp file, then post it to the PR:

```bash
gh pr comment <number> --repo <owner>/<repo> --body-file /tmp/renovate-comment.md
```

Group packages by the file they came from. Do not list the full path of the files. Use the format defined in `~/.claude/skills/updater/templates/FORMAT.md`. 

Focus the detailed sections on updates that matter: breaking changes, security fixes, and major new features.

For packages that only have minor/patch updates with no breaking changes, no security fixes, and no notable features: Only include them in the summary count.

At the end, write a 1-2 sentence summary of what actions we need to take. Style it in bold.

**Quality guidelines:**
- **Be consistent**: if multiple packages share the same breaking change (e.g., all require Node 24), mark it as breaking on ALL of them, not just one.
- **Be specific**: mention the actual infrastructure (e.g., "runs on `namespace-profile-niteo` Namespace cloud runners" not just "runs on CI").
- **Connect the dots**: reference related changes (e.g., "Same runner consideration as checkout above").
- **Informative summary**: explain what counts mean (e.g., "Breaking changes: 1 (Node 24 runner requirement across all 3 actions)").

</output>

<error-handling>

- **Auth errors**: Inform user.
- **Truncated diffs**: Process what is available, note limitation.
- **No version changes**: Print "No package version changes detected."
- **Missing changelogs**: Note "No changelog found" per package, continue.

</error-handling>
