<!-- Managed in https://github.com/teamniteo/claude — edit there, not here.
     If you have project-specific instructions to add, README.md is the best place. -->

# Conventions

- Prefer simple, direct code over abstractions.
- Avoid unnecessary comments and over-engineering.
- Clean up unused code lying around.
- DRY in code is bad, but DRY in tests is good.
- Don't rely on discipline, prefer automated enforcement.
- Old documentation is worse than no documentation: remember to regularly update CLAUDE.md and rules/*.md files.

## Code Style

- Follow existing code style in the file being edited. Read similar files to learn how things are done.
- Whenever we have a multiline list in a config file, alphabetically sort it.
- Always ask clarifying questions when there are multiple valid approaches to a task.
- Run `make check` after editing to ensure code style compliance.

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

NEVER append "Authored by Claude Code" to commit messages.

### User Stories

We have a template for writing stories in `.github/ISSUE_TEMPLATE/user-story.md`. Always follow this template when creating new issues.

- NEVER change the template!
- Only every use existing labels, never create new labels.
- The last AC is always `- [ ] User Story demo is uploaded to this issue`.
