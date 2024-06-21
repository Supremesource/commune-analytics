{
  description = "Commune Analytics";

  nixConfig.extra-substituters = [
    "https://tweag-jupyter.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "tweag-jupyter.cachix.org-1:UtNH4Zs6hVUFpFBTLaA4ejYavPo5EFFqgd7G7FxGW9g="
  ];

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jupyenv.url = "github:tweag/jupyenv";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, jupyenv, poetry2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        p2n = poetry2nix.lib.mkPoetry2Nix {
          inherit pkgs;
        };
        inherit (jupyenv.lib.${system}) mkJupyterlabNew;
        
        jupyterlab = mkJupyterlabNew ({ ... }: {
          nixpkgs = nixpkgs;
          imports = [(import ./kernels.nix)];
        });

        communeAnalytics = p2n.mkPoetryApplication {
          projectDir = ./.;
          python = pkgs.python311;
          # If you have overrides, uncomment the following line and create the file:
          # overrides = import ./nix/poetry2nix-overrides.nix { inherit pkgs p2n; };
        };

      in {
        packages = {
          inherit jupyterlab communeAnalytics;
          default = jupyterlab;
        };

        apps.default = {
          type = "app";
          program = "${jupyterlab}/bin/jupyter-lab";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.python311
            pkgs.poetry
            pkgs.ruff
          ];
        };
      }
    );
}