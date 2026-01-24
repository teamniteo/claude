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
          "code-review@claude-plugins-official" = true;
          "sentry@claude-plugins-official" = true;
        };

        mcpServers = pkgs: {

          # Local server with PAT because remote OAuth broken in Claude Code:
          # https://github.com/anthropics/claude-code/issues/3433
          github = {
            command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
            args = [ "stdio" ];
            env = {
              GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
            };
          };

          mcp-nixos = {
            command = "${mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/mcp-nixos";
          };

          # Token is created on https://niteo.grafana.net/org/serviceaccounts
          mcp-grafana = {
            command = "${pkgs.mcp-grafana}/bin/mcp-grafana";
            env = {
              GRAFANA_URL = "https://niteo.grafana.net";
              GRAFANA_SERVICE_ACCOUNT_TOKEN = "\${GRAFANA_SERVICE_ACCOUNT_TOKEN}";
            };
          };

          prometheus = {
            type = "http";
            url = "https://prometheus.niteo.co/mcp/";
            headers = {
              Authorization = "Basic \${PROMETHEUS_AUTH}";
            };
          };
        };

      };
    };
}
