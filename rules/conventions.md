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