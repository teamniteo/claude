{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  hatchling,
  uv-dynamic-versioning,

  # dependencies
  authlib,
  cyclopts,
  exceptiongroup,
  fakeredis,
  httpx,
  jsonref,
  jsonschema-path,
  mcp,
  openapi-pydantic,
  packaging,
  platformdirs,
  py-key-value-aio,
  pydantic,
  pydocket,
  pyperclip,
  python-dotenv,
  rich,
  uvicorn,
  websockets,
}:

buildPythonPackage rec {
  pname = "fastmcp";
  version = "2.14.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jlowin";
    repo = "fastmcp";
    rev = "v${version}";
    hash = "sha256-iObJwSMeOW3GOGyCPDGqy+Lx2ew+UQ8V+RcPFJrTdmk=";
  };

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  pythonRelaxDeps = [
    "fakeredis"
    "py-key-value-aio"
    "pydocket"
  ];

  dependencies =
    [
      authlib
      cyclopts
      exceptiongroup
      fakeredis
      httpx
      jsonref
      jsonschema-path
      mcp
      openapi-pydantic
      packaging
      platformdirs
      py-key-value-aio
      pydantic
      pydocket
      pyperclip
      python-dotenv
      rich
      uvicorn
      websockets
    ]
    ++ pydantic.optional-dependencies.email;

  pythonImportsCheck = [ "fastmcp" ];

  doCheck = false;

  meta = {
    description = "Fast, Pythonic way to build MCP servers and clients";
    homepage = "https://github.com/jlowin/fastmcp";
    license = lib.licenses.asl20;
    mainProgram = "fastmcp";
    platforms = lib.platforms.all;
  };
}
