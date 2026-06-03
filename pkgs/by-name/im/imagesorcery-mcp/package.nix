{
  lib,
  buildPythonApplication,
  fetchFromGitHub,

  # build-system
  hatchling,

  # dependencies
  fastmcp,
  amplitude-analytics,
  pydantic,
  opencv-python,
  imutils,
  pillow,
  ultralytics,
  requests,
  tqdm,
  huggingface-hub,
  easyocr,
  toml,
  posthog,
  python-dotenv,
}:

buildPythonApplication rec {
  pname = "imagesorcery-mcp";
  version = "0.12.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sunriseapps";
    repo = "imagesorcery-mcp";
    rev = "v${version}";
    hash = "sha256-WfON3kseOoYXo/igB3gsLwceG66Z8IckGRta8m8MfNM=";
  };

  build-system = [ hatchling ];

  # imagesorcery hardcodes its log file next to its own source location, which
  # is the read-only Nix store. Redirect to an XDG-style user state directory.
  postPatch = ''
    substituteInPlace src/imagesorcery_mcp/logging_config.py \
      --replace-fail \
        'LOG_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs", "imagesorcery.log")' \
        'LOG_FILE = os.path.join(os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "imagesorcery-mcp", "imagesorcery.log")'
  '';

  dependencies = [
    fastmcp
    amplitude-analytics
    pydantic
    opencv-python
    imutils
    pillow
    ultralytics
    requests
    tqdm
    huggingface-hub
    easyocr
    toml
    posthog
    python-dotenv
  ];

  doCheck = false;

  meta = {
    description = "MCP server providing image manipulation tools for LLMs";
    homepage = "https://github.com/sunriseapps/imagesorcery-mcp";
    license = lib.licenses.mit;
    mainProgram = "imagesorcery-mcp";
    platforms = lib.platforms.all;
  };
}
