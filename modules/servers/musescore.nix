{ mkServerModule, ... }:
{
  imports = [
    (mkServerModule {
      name = "musescore";
      packageName = "mcp-musescore";
    })
  ];
}
