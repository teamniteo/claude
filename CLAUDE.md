# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working on this project.

For additional context, read README.md files as well.

## Plugins

Use the following plugins when working on user's tasks:

- claude-md-management
- code-review
- sentry

If any of these Plugins is not available, ask the user to install and update
the official plugins marketplace.


## MCP Servers

- **Cloudflare Docs**: Provides up-to-date Cloudflare documentation.
- **GitHub**: Requires `GITHUB_PERSONAL_ACCESS_TOKEN` environment variable. Create a read-only (classic) token at https://github.com/settings/tokens.
- **Grafana**: Requires `GRAFANA_SERVICE_ACCOUNT_TOKEN` environment variable from 1Password.
- **Heroku**: Uses existing Heroku CLI authentication. If unauthenticated, ask the user to run `heroku login`. Get the project's Heroku app name from README.md.
- **ImageSorcery**: Local image manipulation (crop, blur, optimize).
- **Customer.io**: Browser-based OAuth. Use for email campaigns, segments, templates, and workspace data.
- **NixOS (mcp-nixos)**: Query NixOS packages, options, Home Manager, Darwin, and flake information.
- **Prometheus**:
    1. Requires `PROMETHEUS_AUTH` environment variable. Get the password from 1Password then run `export PROMETHEUS_AUTH="$(echo -n 'grafana:<PASSWORD>' | base64)"`.
    2. Requires Niteo VPN connection. If the Prometheus MCP fails to connect, ask the user to connect to the Niteo VPN.
- **Sentry**: Browser-based OAuth. Available via the `sentry` plugin. Use for error monitoring, issue analysis, and root cause investigation.


## Image Manipulation

Use the imagesorcery MCP server for all image manipulation tasks.

When a user is working on an image, offer to help with the following tasks:
- Crop to specific size while focusing on the important part of the image.
- Bluring out sensitive information.
- Optimizing images for faster loading times.


## Development Environment

- Every command needs to be run inside `nix-shell`.

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