# claude

Claude Code configuration shared across all Niteo projects and all Niteans.

## Projects

Projects use `CLAUDE.md` from this repo as their main Claude configuration file.

Examples:
* https://github.com/teamniteo/hakuto/pull/46
* https://github.com/mayetrx/trak/pull/412

Projects can provide additional project-specific instructions by adding it to
README.md or other documentation files.

## Niteans

Niteans use rules, skills and MCPs from this repo in their HomeManager setup of Claude Code.

Examples:
* https://github.com/zupo/dotfiles/commit/7c8df46a69eb15da326d67d55a7e35495a5d566b

Niteans can extend with their personal tooling or preferences, and are encouraged to generalize and contribute back to this repo for other Niteans to benefit.


# Convention

## Skills instead of Commands

Commands were merged into [Skills](https://code.claude.com/docs/en/skills) in v2.1.3. Let's use Skills from now on.

https://www.reddit.com/r/ClaudeAI/comments/1q92wwv/merged_commands_and_skills_in_213_update/

## No need for Plugins

Because we use HomeManager to manage Claude Code, we don't need to use [Plugins](https://code.claude.com/docs/en/plugins).



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
* https://github.com/roman/mcps.nix
* https://docs.customer.io/ai/mcp-server/
* slack mcp
* agentsDir = "${claude-plugins}/plugins/code-simplifier/agents";

      ### Technical preferences:
      - Backend: Python + Pyramid framework, pytest for testing, ruff for linting
      - Frontend: Elm, elm-land
      - DevOps: Nix, OpenAPI, Makefiles, pre-commit-hooks, GitHub Actions
      - Functional programming enthusiast: Nix, Elm
      - Integrates with
        - Heroku for hosting
        - Cloudflare for CDN and DNS
        - Customer.io for emails
        - HelpScout for support
        - Paddle for payments
