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

## MCP Servers

- **Grafana**: Requires `GRAFANA_SERVICE_ACCOUNT_TOKEN` environment variable from 1Password.
- **Prometheus**:
    1. Requires `PROMETHEUS_AUTH` environment variable. Get the password from 1Password then run `export PROMETHEUS_AUTH="$(echo -n 'grafana:<PASSWORD>' | base64)"`.
    2. Requires Niteo VPN connection. If the Prometheus MCP fails to connect, ask the user to connect to the Niteo VPN.

