---
name: weekly-commit-sync
description: Find PRs merged in the last week in a sister project that haven't been ported to this project (and vice versa). Produces a checklist to paste into a tracking issue, then optionally hands off to the port skill.
argument-hint: "<sister repo, e.g. trak or mayetrx/trak> [<YYYY-MM-DD or Nd>]"
allowed-tools:
  - Agent
  - AskUserQuestion
  - Bash(git *)
  - Bash(date *)
  - Bash(ls *)
  - Bash(test *)
  - Bash(jq *)
  - Bash(gh pr diff*)
  - Bash(gh pr list*)
  - Bash(gh pr view*)
  - Glob
  - Grep
  - Read
  - Skill(port)

---

# Weekly Commit Sync

Two sister projects (e.g. Vend forked from Trak) drift apart as each gets its own fixes. Once a week, run this skill to identify which fixes landed in one project but not the other, paste the result into the tracking issue, and act on it — manually or by handing off to the `/port` skill.

## Input

`$ARGUMENTS`:

- **Required**: the sister repo. Either bare (`trak`) or qualified (`mayetrx/trak`). If bare, assume the same owner as the current repo (resolved from `git remote get-url origin`).
- **Optional**: a window start. Either a calendar date (`YYYY-MM-DD`) or a number of days back (`<N>d`, e.g. `10d`). The window always ends at *now*. If absent, the skill asks interactively in `<determine-window>` with sensible Monday-aligned defaults.

The current project (project A) is the current working directory. The sister (project B) is given by the argument.

If `$ARGUMENTS` is empty or the sister can't be parsed, use `AskUserQuestion` to ask for it.

## Steps

<locate-sister-checkout>

The skill needs a local checkout of project B to compare against project A.

1. **Try the sibling**: probe `/path/to/<repo-B>` with `test -d`. If it exists, confirm via `git -C <path> remote get-url origin`.
2. **Otherwise ask** via `AskUserQuestion` for the absolute path; validate the same way.

For both checkouts, fetch and resolve the default branch. Always read from `origin/<default-branch>`, never the working tree:

```
git -C <path> fetch origin --quiet
git -C <path> symbolic-ref refs/remotes/origin/HEAD --short   # e.g. origin/main
```

</locate-sister-checkout>

<determine-window>

The window ends at *now*. Resolve the start:

- `$ARGUMENTS` has `YYYY-MM-DD` → start = that date at 00:00 UTC.
- `$ARGUMENTS` has `<N>d` → start = `now - N days` at 00:00 UTC.
- Otherwise ask via `AskUserQuestion`. With `N = days since most recent Monday`:
  - "Since this Monday" (`N` days ago)
  - "Since previous Monday" (`N+7` days ago) — recommend when `N <= 3`.
  - "Custom — specify days back".

Show `<start ISO> → now (UTC)` and both repo names; confirm before proceeding.

</determine-window>

<analyze-in-parallel>

The two directions (`<repo-B>` → `<repo-A>` and `<repo-A>` → `<repo-B>`) are independent. Dispatch them as two **parallel** `Agent` calls (`subagent_type: general-purpose`) — one per direction — in a single message. Each direction subagent does only **cheap exact-match classification**: `ported` (exact `Port of <URL>` match), `port_in_flight` (open PR with `Port of <URL>` in body), or `missing` (everything else). The expensive semantic assessment of missing PRs happens in `<per-pr-assessment>`.

**Subagent prompt template** (instantiate twice, once per direction with `<source>` / `<target>` swapped):

> You are listing PRs merged in `<source-owner>/<source-repo>` between `<window-start ISO>` and `<window-end ISO>` UTC and classifying each by exact match against `<target-owner>/<target-repo>`'s history.
>
> **Step 1 — list source PRs in window.** Run `gh pr list --repo <source-owner>/<source-repo> --state merged --search "merged:<window-start>..<window-end>" --limit 200 --json number,title,url,author,mergedAt`. Keep only PRs whose `mergedAt` falls inside the window. **Skip bots** (any author with `[bot]` in the login or `author.is_bot == true`).
>
> **Step 2 — list open ports in target.** Run `gh pr list --repo <target-owner>/<target-repo> --state open --limit 200 --json number,url,body`. For each open PR, scan its body for `Port of https://github.com/<source-owner>/<source-repo>/pull/<N>` lines and build a map `source_url → {target_pr_number, target_pr_url}`.
>
> **Step 3 — classify each source PR.** Apply in order; stop at first match:
>
> 3a. **`ported`** — `git -C <target-path> log <target-default-branch> --grep="Port of <PR URL>" --format="%H %s"`. Hit → record short SHA.
> 3b. **`port_in_flight`** — source URL appears in the open-PR map from Step 2. Record `target_pr_number` and `target_pr_url`.
> 3c. **`missing`** — no exact-port evidence; falls through to per-PR semantic assessment in the next stage.
>
> Issue the `git -C ... log` calls in parallel (one Bash tool call each, all in a single message).
>
> Return a JSON array, one object per PR, with: `number`, `title`, `url`, `author`, `merged_at`, `status` (`ported` | `port_in_flight` | `missing`), `ported_sha` (only if `ported`), `target_pr_number` and `target_pr_url` (only if `port_in_flight`).
>
After both subagents return, merge their results. Pass the full set of `missing` PRs to `<per-pr-assessment>`.

</analyze-in-parallel>

<per-pr-assessment>

For every PR currently classified as `missing` (across both directions), spawn a **per-PR subagent** that reads the PR's diff and judges semantically whether it can be ported into the target.

If the missing list is empty, skip this stage.

**Run one direction at a time** (`<repo-B>` → `<repo-A>` first, then `<repo-A>` → `<repo-B>`) so the user gets visible progress between them. Within a direction, dispatch every missing PR's subagent in parallel in a single message. Each subagent has its own context, so the parent's context stays small.

User-visible progress emissions:

1. **Pre-flight**: `Found <N_B_to_A> missing PRs in <repo-B>, <N_A_to_B> in <repo-A>. Checking <repo-B> → <repo-A> first…`
2. **Direction summary** when all of that direction's subagents have returned: `<repo-B> → <repo-A> done: <X> to port, <Y> partial, <Z> inapplicable, <W> already done.`
3. Repeat for `<repo-A> → <repo-B>`: `Now checking <repo-A> → <repo-B>…`, then direction summary.

If one direction has zero missing PRs, skip its emissions and run only the other.

**Per-PR subagent prompt template** (one instance per missing PR):

> You're assessing whether a single source PR can be ported into a sister project. **Do not modify any files. Do not invoke `/port`.** This is dry-run analysis only.
>
> **Source PR**: `<source PR URL>` (in `<source-owner>/<source-repo>`)
> **Target**: `<target-owner>/<target-repo>` (local checkout at `<target-path>`, default branch `<target-default-branch>`)
>
> **Step 1 — fetch the PR.** Use `gh`:
> - `gh pr view <N> --repo <source-owner>/<source-repo> --json title,body` for title, body, intent.
> - `gh pr diff <N> --repo <source-owner>/<source-repo>` for the full diff. Derive each file's status from the diff headers: `new file mode` → `added`, `deleted file mode` → `removed`, `rename from`/`rename to` → `renamed`, otherwise `modified`.
>
> **Step 2 — assess against target.**
>
> First, cache the target tree as a path set (one Bash call, then hold the result in your working memory):
>
> ```
> git -C <target-path> ls-tree -r <target-default-branch> --name-only
> ```
>
> Use this set to answer "does this path exist?" in your head. For finer-grained reads (specific lines, hunks, symbols), use `Read`, `Glob`, `Grep`.
>
> For each changed file:
> - **Modified/renamed/removed**: is the file in the target tree set? If not, try the path with `<source-repo>` segments replaced by `<target-repo>`. If the file exists, use `Read` on it to check whether the changed lines/functions/symbols are present (so the modification has something to bite onto).
> - **Added**: is the parent directory in the target tree set (literal or translated)? Are the symbols/imports the new file references (other modules, helpers) present in target — use `Grep` to confirm.
> - **Cross-references**: if the PR introduces a new module/concept (e.g. a "Qualification" feature), use `Grep` to look for any prior trace of that concept in target. Absence is a strong signal of inapplicability.
>
> **Step 3 — form a verdict.** Pick exactly one:
>
> - **`applies_cleanly`** — every changed file has a target counterpart, referenced symbols are present, the diff would apply with no semantic surprises. *Reason*: short summary of what's being ported.
> - **`partial`** — most of the change applies, but specific pieces are missing or differ (e.g. "modifies `auth/views.py` which exists, but adds a call to `sso.foo()` and trak has no `sso` module"). *Reason*: name the specific friction points so the user knows what to bridge.
> - **`inapplicable`** — the change is to a concept/module that doesn't exist in target at all (e.g. removing TMF docs from a subcontractor module, when target has no subcontractor concept). *Reason*: name the missing concept/module.
> - **`appears_already_done`** — the change is already present in target (the post-diff state of source files matches target's current state). *Reason*: where the equivalent change lives in target (file path or short SHA if you spotted one).
>
> Be honest about uncertainty. If you can't tell, prefer `partial` and say what you'd need to know.
>
> Return JSON: `{"pr_number": <N>, "verdict": "<verdict>", "reason": "<one-line>"}`.

After all per-PR subagents return, merge their verdicts back into the per-direction PR lists. Continue to `<output-checklist>`.

</per-pr-assessment>

<output-checklist>

Print one markdown block, ready to paste into a GitHub issue comment. Use this exact shape:

```markdown
## Weekly commit sync — from <start DD Mon YYYY>

**Window**: `<start ISO>` → now (UTC)
**Projects**: `<owner>/<repo-A>` ↔ `<owner>/<repo-B>`

---

### Port from `<repo-B>` → `<repo-A>`

#### ⚠️ To port
- [ ] [#<N>](<URL>) — <title> (by @<author>) — *<reason>*

#### 🔍 Partial fit
- [ ] [#<N>](<URL>) — <title> (by @<author>) — *<reason>*

#### 🚧 Port in progress
- [ ] [#<N>](<URL>) — <title> (by @<author>) — port open at [`<repo>`#<M>](<target PR URL>)

#### ⏭️ Probably safe to skip
- [ ] [#<N>](<URL>) — <title> (by @<author>) — *<reason>*

#### ☑️ Already ported
- [x] [#<N>](<URL>) — <title> (by @<author>) — `<short SHA>`

#### ❓ Possibly already ported — verify
- [x] [#<N>](<URL>) — <title> (by @<author>) — *<reason>*

---

### Port from `<repo-A>` → `<repo-B>`

(same six sub-buckets)
```

Bucket rules (ordered by user attention — first is the read-carefully bucket):

- **⚠️ To port** — `verdict == applies_cleanly`. High-confidence portable — every changed file has a target counterpart and referenced symbols are present.
- **🔍 Partial fit** — `verdict == partial`. Most of the change applies, but pieces are missing or differ. The reason names the friction.
- **🚧 Port in progress** — direction-level `port_in_flight`. Someone has an open PR in the target referencing this source PR. Show the target PR link so the user can review/approve it instead of starting a new port.
- **⏭️ Probably safe to skip** — `verdict == inapplicable`. The change is to a concept/module that doesn't exist in target at all. Reason names the missing concept; section heading conveys the warning, so don't repeat ⚠️ per item.
- **☑️ Already ported** — direction-level `ported` (exact `Port of <URL>` match).
- **❓ Possibly already ported** — `verdict == appears_already_done`. The per-PR subagent found the equivalent change already present in target. Reason names where.

Other rules:

- Sort within each sub-bucket by merged-at ascending (oldest first).
- Keep PR titles verbatim.

After the block, print a one-line summary outside the block: `<X> to port from B (<P> partial, <O> open in flight, <S> safe to skip, <D> already done), <X'> to port from A (...).`

</output-checklist>

<act>

Use `AskUserQuestion` to ask how the user wants to proceed. Offer:

1. **Port all unported PRs from `<repo-B>` → `<repo-A>`** — invoke the `/port` skill once with all source PR URLs joined by spaces. The port skill handles them as a single combined changeset.
2. **Port a subset** — ask which PR numbers to port, then invoke `/port <URL> <URL> ...` with those.
3. **Stop here** — the user will paste the checklist into the tracking issue and decide later.

Only offer options 1/2 for the `<repo-B>` → `<repo-A>` direction (porting *into* the current project). For `<repo-A>` → `<repo-B>`, the user has to switch into the other project's working copy first; just remind them.

If the user picks 1 or 2, hand off to `/port`. Do not attempt to port manually inside this skill.

</act>

## Pitfalls

- **Don't auto-port.** Always wait for the user's explicit choice in `<act>`. The whole point of the checklist is human review.
- **Don't trust title-only matches as "ported".** Two unrelated PRs can share a title (especially `fix: typo`). The per-PR assessment marks these as "possibly already ported" for human verification, never as ported.
- **Don't recompute "ported" status across all of history.** Only check whether *this week's* PRs from one side appear as ports on the other side. Older PRs are out of scope for the weekly sync.
