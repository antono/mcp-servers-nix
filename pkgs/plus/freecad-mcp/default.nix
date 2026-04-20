{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "freecad-mcp";
  version = "0.1.17";

  src = fetchFromGitHub {
    owner = "neka-nat";
    repo = "freecad-mcp";
    rev = "8694c3214947efedfcf2423b3babad80af80d299";
    hash = "sha256-EYLr7FFIjrPmgngGvYJlQzRPEbYfvp84pIlCbazl/+8=";
  };

  pyproject = true;

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    mcp
    validators
  ];

  meta = {
    description = "FreeCAD MCP server";
    homepage = "https://github.com/neka-nat/freecad-mcp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ antono ];
    mainProgram = "freecad-mcp";
  };
}
