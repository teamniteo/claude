<!-- Managed in https://github.com/teamniteo/claude — edit there, not here.
     If you have project-specific instructions to add, README.md is the best place. -->

# Conventions

Push back if you see a better angle. Tell the user if they are asking for the wrong thing.

## Key principles

1. **No fluff, ever** — Every word needs to earn its place. "i think we could potentially consider trying..." becomes "try this:"
2. **Surgical intervention only** — Touch what needs touching. Nothing else. The code works? Don't "improve" it while you're in there. Fix the bug, verify the fix, get out.
3. **Simplicity is the goal, not a compromise** — The cleanest solution wins. Not the clever one. Not the elegant abstraction that will "scale better." The one that a tired human at 3am can read and understand without context.
4. **Verify everything** — "Did this actually work?" — mandatory question after every action. No assumptions. No "it should work." No "that usually fixes it." Check. Confirm. Then move on.
5. **Obsessive evolution** — Every interaction is data. What confused the user? What took three attempts when it should have taken one? Update CLAUDE.md with these insights.
6. **Automation over discipline** — Don't rely on user's discipline, prefer automated enforcement.
7. **DRY tests, WET code** — DRY in code is bad, but DRY in tests is good.

## Write less code

The best code is the code never written. Before writing any, stop at the first rung that holds:

1. Does this need to be built at all? (YAGNI)
2. Does the standard library already do it? Use it.
3. Does a native platform feature cover it? Use it.
4. Does an already-installed dependency solve it? Use it.
5. Can it be one line? Make it one line.
6. Only then: write the minimum code that works.

Lazy means efficient, not careless. Deletion over addition, boring over clever, fewest files possible. Never cut corners on input validation, error handling, security, accessibility, or anything explicitly requested.

## Code Style

- Follow existing code style in the file being edited. Read similar files to learn how things are done.
- Whenever we have a multiline list in a config file, alphabetically sort it.
- Always ask clarifying questions when there are multiple valid approaches to a task.
- Run `make check` after editing to ensure code style compliance.
- When using camelCase, treat abbreviations just like ordinary words (e.g., `getHttpUrl` not `getHTTPURL`, `parseJsonApi` not `parseJSONAPI`).

## Comments

Code should be self-documenting. If you need a comment to explain WHAT the code does, consider refactoring to make it clearer instead of adding a comment.

Comments are only acceptable when they explain WHY something is done a certain way,
and should include a link to the GitHub issue or comment that explains the reasoning.

### Unacceptable Comments
- Comments that repeat what code does
- Commented-out code (delete it)
- Obvious comments ("increment counter")
- Comments instead of good naming
- Comments about updates to old code ("<- now supports xyz")

## git

NEVER push directly to `main`. Always work on a feature branch and create a Pull Request. This rule has NO exceptions — not even for "quick fixes" or single commits.

Before any work, always ask the user what GitHub Issue they are working on. Then check the current branch. If you are on `main`, ask the user which branch to checkout (list 5 most recent branches) or to create a new one. Propose the branch name based on the GitHub Issue that is being worked on. When creating a new branch, always base it off the latest `origin/main`.

### Branch naming convention

Each branch name should start with a type prefix, followed by a slash, and then a concise description of the work being done. Use hyphens to separate words in the description.

The prefix can be one of the following:
- `feat`: for new features or enhancements
- `fix`: for bug fixes
- `chore`: other

If the branch contains a `chore` and a `fix` commit, use `fix` as the prefix.
If the branch contains a `chore` and a `feat` commit, use `feat` as the prefix.
If the branch contains a `fix` and a `feat` commit, use `feat` as the prefix.

### Commit message convention

Each commit message should start with a type prefix, followed by a colon, a space, and an uppercase letter.

The prefix can be one of the following:
- `feat`: for new features or enhancements
- `fix`: for bug fixes
- `chore`: other

Every commit message should end with one or multiple lines of `Refs #<issue-number>`, linking to the relevant GitHub issue(s).

Commit titles should be limited to 50 characters and other lines to 72 characters. This is not a hard limit, if it makes sense, you can break it.

If there is additional cleanup included in the commit, add it to the body like so:

```
Also:
- clean up X
- update Y
- remove Z
```

NEVER append "Authored by Claude Code" to commit messages.

### User Stories

We have a template for writing stories in `.github/ISSUE_TEMPLATE/user-story.md`. Always follow this template when creating new issues. Always ask before creating an issue and posting it to GitHub.

- NEVER change the template!
- Only every use existing labels, never create new labels.
- The last AC is always `- [ ] User Story demo is uploaded to this issue`.

### Pull Requests

PR body = commit message body. Nothing else. No ## Summary, no ## Test plan, no rephrasing. For a single-commit PR, copy the commit message verbatim. For a multi-commit PR, copy the main commit's message verbatim and append an `Also:` block listing the other commit titles, like so:
  
```
Also:
- add X
- refactor Y
- document Z
```

If you find yourself writing a section heading in a PR body, stop — you're doing it wrong. 

## Documentation

After finishing your work, look for `documentation/` and `frontend/static/documentation/` folders. These contain our documentation. If applicable, update them based on the work you have just performed.

Also update any README.md files you encounter, if applicable.

## Enums

Enums should have standardized values across the stack: snake_case in Python and Postgres, camelCase in API JSON and Elm, human-readable labels via `x-labels`.

In Python:

* <enum>.name: snake_case, for DB storage, Python code, logging, metrics.
* <enum>.value: camelCase, for building response dicts, which happens automatically with `enum_adapter` in the JSON renderer, so you never need to call `.value` directly.
* <enum>.label: human-readable, for auditlog messages, emails, PDF/CVS exports.

In Elm:

* type constructors: for Elm code
* label functions: <enum>Label, for UI display
