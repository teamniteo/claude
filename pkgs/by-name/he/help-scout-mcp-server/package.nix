{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "help-scout-mcp-server";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "drewburchfield";
    repo = "help-scout-mcp-server";
    rev = "v${version}";
    hash = "sha256-DBOUfnbFKuxDIKH84UlwKrF23FwzNumZ2gBMJtnRRmk=";
  };

  npmDepsHash = "sha256-au6r74mUvXo61Mb9etCZnbfeIuM/kWDLS5G6XiMuuyg=";

  meta = {
    description = "Help Scout MCP server";
    homepage = "https://github.com/drewburchfield/help-scout-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "help-scout-mcp-server";
    platforms = lib.platforms.all;
  };
}
