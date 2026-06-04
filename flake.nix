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

        skills =
          let
            skillDirs = builtins.attrNames (builtins.readDir ./skills);
          in
          builtins.listToAttrs (
            builtins.map (name: {
              inherit name;
              value = ./skills + "/${name}";
            }) skillDirs
          );

        # You have to have the official plugins marketplace installed and updated
        enabledPlugins = {
          "claude-md-management@claude-plugins-official" = true;
          "code-review@claude-plugins-official" = true;
          "sentry@claude-plugins-official" = true;
        };

        # Allow ~safe read-only operations by default
        permissions.allow = [
          "Bash(gh auth token*)"
          "Bash(gh issue list*)"
          "Bash(gh issue view*)"
          "Bash(gh pr diff*)"
          "Bash(gh pr list*)"
          "Bash(gh pr view*)"
          "Bash(gh search*)"
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
          "mcp__heroku__*"
          "mcp__mcp-grafana__*"
          "mcp__mcp-nixos__*"
          "mcp__plugin_sentry_sentry__*"
          "mcp__imagesorcery-mcp__*"
          "mcp__prometheus__*"
          "mcp__help-scout__*"
        ];

        mcpPackages =
          pkgs:
          let
            fastmcp = pkgs.python3Packages.callPackage ./pkgs/by-name/fa/fastmcp/package.nix { };
          in
          {
            help-scout-mcp-server = pkgs.callPackage ./pkgs/by-name/he/help-scout-mcp-server/package.nix { };
            inherit fastmcp;
            imagesorcery-mcp = pkgs.python3Packages.callPackage ./pkgs/by-name/im/imagesorcery-mcp/package.nix {
              inherit fastmcp;
            };
          };

        mcpServers = pkgs: {

          cloudflare-docs = {
            type = "http";
            url = "https://docs.mcp.cloudflare.com/mcp";
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
            command = "${(self.lib.mcpPackages pkgs).imagesorcery-mcp}/bin/imagesorcery-mcp";
          };

          # Requires HELPSCOUT_APP_ID and HELPSCOUT_APP_SECRET in environment
          # Get credentials from Help Scout → Your Profile → My Apps -> Create App
          # Name it "Claude MCP", the URL can be anything (e.g. https://niteo.co)
          help-scout = {
            command = "${(self.lib.mcpPackages pkgs).help-scout-mcp-server}/bin/help-scout-mcp-server";
          };
        };

      };
    };
}
