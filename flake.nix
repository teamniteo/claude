{
  description = "Shared Claude Code configuration for Niteo";

  inputs = {
    mcp-nixos.url = "github:utensils/mcp-nixos";
  };

  outputs =
    { self, mcp-nixos }:
    {
      lib = {

        # Projects import this:
        claudeContent = builtins.readFile ./CLAUDE.md;

        # Niteans's HomeManager setup imports these:
        rules = {
          comments = builtins.readFile ./rules/comments.md;
        };

        enabledPlugins = {
          "github@claude-plugins-official" = true;
          "sentry@claude-plugins-official" = true;
          "code-review@claude-plugins-official" = true;
        };

        mcpServers = pkgs: {

          mcp-nixos = {
            command = "${mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/mcp-nixos";
          };

          # Authentication via PROMETHEUS_AUTH environment variable
          # export PROMETHEUS_AUTH="$(echo -n 'grafana:<PASSWORD>' | base64)"
          prometheus = {
            type = "http";
            url = "https://cruncher.niteo.co/mcp/";
            headers = {
              Authorization = "Basic $PROMETHEUS_AUTH";
            };
          };
        };

      };
    };
}
