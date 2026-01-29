# Niteo Claude

Claude Code configuration shared across all Niteo projects and all Niteans.

## Projects

Projects use `rules/` from this repo in their work folders to tell Claude how our code looks like, what conventions to follow, and what commands are available.

Any project-specific instructions are added to the project's own `CLAUDE.md`.

## Niteans

Niteans use skills and MCPs from this repo in their HomeManager setup of Claude,
so that it gains Niteo-specific capabilities.

Niteans are free to expand with their personal tooling or preferences, and are encouraged to generalize and contribute back to this repo for other Niteans to benefit.


# Convention

## Skills instead of Commands

Commands were merged into [Skills](https://code.claude.com/docs/en/skills) in v2.1.3. Let's use Skills from now on.

https://www.reddit.com/r/ClaudeAI/comments/1q92wwv/merged_commands_and_skills_in_213_update/

## No need for Plugins

Because we use HomeManager to manage Claude Code, we don't need to use [Plugins](https://code.claude.com/docs/en/plugins).



TODO:
* how to run playwright, with PWDEBUG
* how to run a single unit test
* keep 100% test coverage
* Keep SKILL.md under 500 lines for optimal performance. If your content exceeds this, split detailed reference material into separate files.
* prepend all commit messages with fix, feature, cleanup, chore, ...
    -> can we have a pre-commit check for this?
* https://code.claude.com/docs/en/hooks-guide#custom-notification-hook
* Query production databases: heroku config | grep DATABASE_READONLY_URL to get connection string, then claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "<connection string>"
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
* https://github.com/anthropics/claude-plugins-official/blob/main/plugins/code-simplifier/agents/code-simplifier.md
* https://github.com/anthropics/claude-plugins-official/tree/main/plugins/commit-commands/commands
* https://github.com/anthropics/claude-plugins-official/blob/main/plugins/code-review/commands/code-review.md
* slack mcp
* agentsDir = "${claude-plugins}/plugins/code-simplifier/agents";
* document OpenAPI glue between backend and frontend