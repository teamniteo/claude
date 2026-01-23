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

Niteans use rules, skills and MCPs from this repo in their HomeManager setup of Claude Code. They can extend them with their personal tooling and preferences, but are
encouraged to generalize and contribute back to this repo.



# Convention

## Skills instead of Commands

Commands were merged into Skills in v2.1.3. Let's use Skills from now on.

https://www.reddit.com/r/ClaudeAI/comments/1q92wwv/merged_commands_and_skills_in_213_update/

## No need for Plugins

Because we use HomeManager to manage Claude Code, we don't need to use plugins.