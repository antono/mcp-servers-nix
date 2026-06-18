{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  makeWrapper,
}:
let
  pythonEnv = python3.withPackages (ps: [
    ps.mcp
    ps.websockets
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mcp-musescore";
  version = "0-unstable-2026-04-23";

  src = fetchFromGitHub {
    owner = "ghchen99";
    repo = "mcp-musescore";
    rev = "828eb9be5acce90072d7301c81bea9efe0514354";
    hash = "sha256-mig1hSABip+V1pGBDEqGiXLQDk24KfqXYs8Vq1zLsdY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # Upstream ships no packaging metadata (no pyproject.toml/setup.py), just a
  # top-level server.py importing from ./src. Install the sources verbatim and
  # wrap the interpreter; Python puts the script's directory on sys.path so the
  # `src` package resolves at runtime.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mcp-musescore
    cp -r server.py src $out/share/mcp-musescore/

    # The QML plugin must be installed into MuseScore's plugins directory by the
    # user; ship it here for reference.
    install -Dm644 musescore-mcp-websocket.qml \
      $out/share/mcp-musescore/musescore-mcp-websocket.qml

    makeWrapper ${pythonEnv}/bin/python $out/bin/mcp-musescore \
      --add-flags "$out/share/mcp-musescore/server.py"

    runHook postInstall
  '';

  meta = {
    description = "MCP server to control MuseScore (compose music, add lyrics, navigate scores)";
    homepage = "https://github.com/ghchen99/mcp-musescore";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ antono ];
    mainProgram = "mcp-musescore";
    platforms = lib.platforms.all;
  };
})
