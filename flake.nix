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

        # You have to have the official plugins marketplace installed and updated
        enabledPlugins = {
          "claude-md-management@claude-plugins-official" = true;
          "code-review@claude-plugins-official" = true;
          "sentry@claude-plugins-official" = true;
        };

        permissions.allow = [
          "Read(/nix/store/*)"
          "Read(nix flake show *)"
          "Read(nix eval *)"
          "WebFetch"
          "WebSearch"
          "mcp__cloudflare-docs__*"
          "mcp__customerio__*"
          "mcp__github__*"
          "mcp__heroku__*"
          "mcp__mcp-grafana__*"
          "mcp__mcp-nixos__*"
          "mcp__plugin_sentry_sentry__*"
          "mcp__imagesorcery-mcp__*"
          "mcp__prometheus__*"
        ];

        mcpServers = pkgs: {

          cloudflare-docs = {
            type = "http";
            url = "https://docs.mcp.cloudflare.com/mcp";
          };

          # Local server with PAT because remote OAuth broken in Claude Code:
          # https://github.com/anthropics/claude-code/issues/3433
          github = {
            command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
            args = [ "stdio" ];
            env = {
              GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
            };
          };

          # Login with `heroku login`
          heroku = {
            command = "${pkgs.heroku}/bin/heroku";
            args = [ "mcp:start" ];
            env = {
              PATH = "${pkgs.nodejs}/bin:${pkgs.heroku}/bin";
            };
          };

          # Token is created on https://niteo.grafana.net/org/serviceaccounts
          # and is saved in 1Password
          mcp-grafana = {
            command = "${pkgs.mcp-grafana}/bin/mcp-grafana";
            env = {
              GRAFANA_URL = "https://niteo.grafana.net";
              GRAFANA_SERVICE_ACCOUNT_TOKEN = "\${GRAFANA_SERVICE_ACCOUNT_TOKEN}";
            };
          };

          mcp-nixos = {
            command = "${mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/mcp-nixos";
          };

          # export PROMETHEUS_AUTH="$(echo -n 'grafana:<PASSWORD_FROM_1P>' | base64)"
          prometheus = {
            type = "http";
            url = "https://prometheus.niteo.co/mcp/";
            headers = {
              Authorization = "Basic \${PROMETHEUS_AUTH}";
            };
          };

          customerio = {
            type = "http";
            url = "https://mcp-eu.customer.io/mcp";
          };

          imagesorcery-mcp = {
            command = "${pkgs.uv}/bin/uvx";
            args = [ "imagesorcery-mcp" ];
          };
        };

      };
    };
}
