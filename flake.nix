{
  description = "Shared Claude Code configuration for Niteo";

  inputs = {
    mcp-nixos.url = "github:utensils/mcp-nixos";
  };

  outputs =
    { self, mcp-nixos }:
    {
      lib = {

        rules =
          let
            files = builtins.attrNames (builtins.readDir ./rules);
            mdFiles = builtins.filter (name: builtins.match ".*\\.md" name != null) files;
          in
          builtins.listToAttrs (
            builtins.map (name: {
              name = builtins.replaceStrings [ ".md" ] [ "" ] name;
              value = builtins.readFile (./rules + "/${name}");
            }) mdFiles
          );

        # You have to have the official plugins marketplace installed and updated
        enabledPlugins = {
          "claude-md-management@claude-plugins-official" = true;
          "code-review@claude-plugins-official" = true;
          "sentry@claude-plugins-official" = true;
        };

        # Allow ~safe read-only operations by default
        permissions.allow = [
          "Bash(git branch*)"
          "Bash(git diff*)"
          "Bash(git log*)"
          "Bash(git remote*)"
          "Bash(git show*)"
          "Bash(git status*)"
          "Bash(git tag*)"
          "Bash(nix eval *)"
          "Bash(nix flake metadata*)"
          "Bash(nix flake show*)"
          "Bash(nix path-info *)"
          "Bash(nix search *)"
          "Bash(wc *)"
          "Bash(which *)"
          "Read(/nix/store/*)"
          "Read(nix eval *)"
          "Read(nix flake show *)"
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
          "mcp__help-scout__*"
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

          # Requires HELPSCOUT_APP_ID and HELPSCOUT_APP_SECRET in environment
          # Get credentials from Help Scout → Your Profile → My Apps -> Create App
          # Name it "Claude MCP", the URL can be anything (e.g. https://niteo.co)
          help-scout = {
            type = "stdio";
            command = "${pkgs.bash}/bin/bash";
            args = [ "-c" "PATH=${pkgs.nodejs}/bin:$PATH npx help-scout-mcp-server" ];
          };
        };

      };
    };
}
