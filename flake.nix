{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      lib = import ./lib;

      flakeModule = ./modules/flake-parts.nix;

      devenvModules.default = ./modules/devenv.nix;

      homeManagerModules.default = ./modules/home-manager.nix;

      packages = forAllSystems (
        system: (import ./. { pkgs = import nixpkgs { inherit system; }; }).packages
      );

      overlays.default = import ./overlays;

      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          update-module-docs = pkgs.writeShellApplication {
            name = "update-module-docs";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.nix
            ];
            text = ''
              generated=$(nix build --no-link --print-out-paths -f docs/options-doc.nix optionsCommonMark)
              install -m 644 "$generated" docs/module-options.md
            '';
          };
        in
        pkgs.nixfmt-tree.override {
          runtimeInputs = [ update-module-docs ];
          settings = {
            formatter.module-docs = {
              command = "update-module-docs";
              includes = [ "*.nix" ];
            };
          };
        }
      );

      checks = lib.foldr (x: acc: lib.recursiveUpdate x acc) { } [
        (forAllSystems (system: import ./tests { pkgs = import nixpkgs { inherit system; }; }))
        (forAllSystems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            examples = import ./examples { inherit pkgs; };
          in
          # exclude example-signoz from checks to avoid requiring external tenant config
          lib.removeAttrs examples [ "example-signoz" ]
        ))
        # module-options-doc is Linux-only: some plus packages produce platform-specific
        # derivation metadata on macOS, causing the generated docs to differ from the
        # Linux-committed docs/module-options.md. Run the check only on Linux.
        (lib.genAttrs [ "aarch64-linux" "x86_64-linux" ] (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              # playwright.executable defaults to google-chrome (unfree) on macOS
              config = {
                allowUnfree = true;
                allowInsecurePredicate = _: true;
              };
            };
          in
          {
            module-options-doc = (import ./docs/options-doc.nix { inherit pkgs; }).check;
          }
        ))
        self.packages
      ];
    };
}
