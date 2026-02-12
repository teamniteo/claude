<!-- Managed in https://github.com/teamniteo/claude — edit there, not here.
     If you have project-specific instructions to add, README.md is the best place. -->

# Tooling

## Plugins

Use the following plugins when working on user's tasks:

- claude-md-management
- code-review
- sentry

If any of these Plugins is not available, ask the user to install and update
the official plugins marketplace.

## MCP Servers

- **Cloudflare Docs**: Provides up-to-date Cloudflare documentation.
- **GitHub**: Requires `GITHUB_PERSONAL_ACCESS_TOKEN` environment variable. Create a read-only (classic) token at https://github.com/settings/tokens. Always use this MCP instead of the `gh` CLI command.
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

Use the imagesorcery MCP server for any image manipulation tasks.

When a user is working on an image, offer to help with the following tasks:
- Crop to specific size while focusing on the important part of the image.
- Bluring out sensitive information.
- Optimizing images for faster loading times.
