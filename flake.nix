{
  description = "Shared Claude Code configuration for Niteo";

  outputs = { self }: {
    lib = {
      # Raw markdown content as a string
      claudeContent = builtins.readFile ./CLAUDE.md;

      # Rules as attribute set (name -> content)
      rules = {
        # "testing" = builtins.readFile ./rules/testing.md;
      };

      # Commands as attribute set (name -> content)
      commands = {
        # "pr" = builtins.readFile ./commands/pr.md;
      };
    };
  };
}
