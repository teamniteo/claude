# Development Guidelines

Read the README.md files in this repository to learn about project-specific setup, commands, and architecture.

## Development Environment

- Every command needs to be run inside `nix-shell`

## Code Style

- **Consistency**: Follow existing code style in the file being edited. Read similar files to learn how things are done.
- **Python**: ruff formatting (88 char line limit), type annotations required
- **Imports**: First all `from x import y` imports, newline, then all `import z` imports, both alphabetically sorted
- **Naming**: snake_case for functions/variables, CamelCase for classes, ALL_CAPS for constants
- **Error handling**: Use HTTP exceptions with JSON payloads, proper status codes
- **Tests**: High coverage, `test_` prefix, clear setup/execution/assertion pattern
- **Docstrings**: Brief first line, details after blank line. Never use `Args:` and `Returns:` - use type annotations instead
- **Elm**: elm-format for frontend code
- **Lists**: Whenever we have a multiline list in a config file, alphabetically sort it.

Run `make check` before committing to ensure code style compliance.

## Testing

- Use `pytest` for Python tests.
- Use `playwright` for end-to-end tests.
- 100% test coverage is enforced.
- Write tests for all new features and bug fixes.
- Follow the naming pattern of existing test files and cases.
- Use the `responses` library for mocking external HTTP requests - **never use `@patch`**.



TODO:
* Always ask clarifying questions when there are multiple valid approaches to a task.
* Read README's in `backend/`, `frontend/`, `nix/`, etc.
* how to run playwright, with PWDEBUG
* how to run a single unit test
* always use nix-shell
* keep 100% test coverage
* `make lint-all` and `make types`
    * we had make types because it was slow, move to pre-commit
* MCP for image optimisation / squishing
* Use @ to quickly include files or directories
    ```Explain the logic in @src/utils/auth.js```
    ```Show me the data from @github:repos/owner/repo/issues```
* Keep SKILL.md under 500 lines for optimal performance. If your content exceeds this, split detailed reference material into separate files.
* prepend all commit messages with fix, feature, cleanup, chore, ...
    -> can we have a pre-commit check for this?
* https://code.claude.com/docs/en/hooks-guide#custom-notification-hook
* Query production databases: heroku config | grep DATABASE_READONLY_URL to get connection string, then claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "<connection string>"
* claude mcp add --transport http cloudflare https://bindings.mcp.cloudflare.com/mcp
* claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
* claude mcp add --transport http github https://api.githubcopilot.com/mcp/
* https://code.claude.com/docs/en/sandboxing
* Privacy settings can be changed at any time at claude.ai/settings/data-privacy-controls.
* https://code.claude.com/docs/en/settings -> companyAnnouncements
* https://code.claude.com/docs/en/settings#attribution-settings
* https://code.claude.com/docs/en/statusline
* forceLoginMethod
* https://code.claude.com/docs/en/memory#claude-md-imports
* branch name conventions


