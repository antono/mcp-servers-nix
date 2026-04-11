{
  config,
  pkgs,
  lib,
  mkServerModule,
  ...
}:
let
  cfg = config.programs.argocd;
in
{
  imports = [
    (mkServerModule {
      name = "argocd";
      packageName = "argocd-mcp";
    })
  ];

  options.programs.argocd = {
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Argo CD instance URL (e.g., https://argocd.example.com).
      '';
      example = "https://argocd.example.com";
    };

    apiToken = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Argo CD API token for authentication.
        For security reasons, use passwordCommand to retrieve this instead of hardcoding.
      '';
    };

    readOnly = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable read-only mode to disable mutation tools (create, update, delete, sync applications).
      '';
    };

    tlsRejectUnauthorized = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Set to false for self-signed certificates or private CAs.
      '';
    };
  };

  config.settings.servers = lib.mkIf cfg.enable {
    argocd = {
      args = lib.optionals (cfg.type != null) [ cfg.type ];
      env =
        (lib.optionalAttrs (cfg.baseUrl != "") { ARGOCD_BASE_URL = cfg.baseUrl; })
        // (lib.optionalAttrs (cfg.apiToken != "") { ARGOCD_API_TOKEN = cfg.apiToken; })
        // lib.optionalAttrs cfg.readOnly { MCP_READ_ONLY = "true"; }
        // lib.optionalAttrs (!cfg.tlsRejectUnauthorized) { NODE_TLS_REJECT_UNAUTHORIZED = "0"; };
    };
  };
}
