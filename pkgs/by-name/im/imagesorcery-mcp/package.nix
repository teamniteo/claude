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

  # imagesorcery assumes it runs from a writable source checkout: it hardcodes
  # its log file next to its own source location, and on startup chdirs into
  # that source root to create config.toml / models / .env there. Under Nix
  # that location is the read-only store, so redirect both to XDG-style
  # per-user directories.
  postPatch = ''
    substituteInPlace src/imagesorcery_mcp/logging_config.py \
      --replace-fail \
        'LOG_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs", "imagesorcery.log")' \
        'LOG_FILE = os.path.join(os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "imagesorcery-mcp", "imagesorcery.log")'

    substituteInPlace src/imagesorcery_mcp/server.py \
      --replace-fail \
        'project_root = Path(__file__).parent.parent.parent
os.chdir(project_root)' \
        'project_root = Path(os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share"))) / "imagesorcery-mcp"
project_root.mkdir(parents=True, exist_ok=True)
os.chdir(project_root)'
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
