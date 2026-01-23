{
  description = "Shared Claude Code configuration for Niteo";

  inputs = {
    mcp-nixos.url = "github:utensils/mcp-nixos";
  };

  outputs =
    { self, mcp-nixos }:
    {
      lib = {
        claudeContent = builtins.readFile ./CLAUDE.md;

        rules = {
          comments = builtins.readFile ./rules/comments.md;
        };

        mcpServers = pkgs: {
          mcp-nixos = {
            command = "${mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/mcp-nixos";
          };
        };
      };
    };
}
