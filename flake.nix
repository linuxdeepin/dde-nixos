{
  description = "dde for nixos";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        deepinPkgs = import ./packages { inherit pkgs; };
        deepin = flake-utils.lib.flattenTree deepinPkgs;
      in
      rec {
        defaultPackage = pkgs.stdenv.mkDerivation {
          name = "deepin-meta";
          buildInputs = nixpkgs.lib.attrsets.attrValues packages.deepin;
        };
        packages = deepin;
        devShells = builtins.mapAttrs (
          name: value: 
            pkgs.mkShell {
              nativeBuildInputs = deepin.${name}.nativeBuildInputs;
              buildInputs = deepin.${name}.buildInputs;
           }
        ) deepin;
      }
    ) // {
      overlay = self: super: {
        deepin = (import ./packages { pkgs = super.pkgs; });
      };
      nixosModule = { config, lib, pkgs, ... }:
        with lib;
        let
          xcfg = config.services.xserver;
          cfg = xcfg.desktopManager.deepin;
        in
        {
          options = {
            services.xserver.desktopManager.deepin.enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable Deepin desktop manager";
            };
          };
          config = mkIf cfg.enable {
            services.xserver.displayManager.sessionPackages = [ pkgs.deepin.core ];
            ## services.xserver.displayManager.lightdm.theme = mkDefault "deepin";
            ## services.accounts-daemon.enable = true;

            environment.pathsToLink = [ "/share" ];
            environment.systemPackages =
              let
                deepinPkgs = with pkgs.deepin; [
                  calculator
                ];
                plasmaPkgs = with pkgs.libsForQt5; [
                  kwin
                ];
              in deepinPkgs ++ plasmaPkgs;
          };
      };
    };
}
