{
  description = "Infuse – Deep attribute surgery for Nix (flake wrapper)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        infuse = import ./default.nix { lib = final.lib; };
      };
    in
    (flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        libInfuse = import ./default.nix { lib = pkgs.lib; };
      in {
        # 1. primary deliverable – the library packaged as a derivation for tooling
        packages.infuse = pkgs.runCommand "infuse-nix" { } ''
          mkdir -p $out
          cp ${./default.nix} $out/infuse.nix
        '';

        # 2. edit-focused dev shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ just nixpkgs-fmt ];
          shellHook = "just --list";
        };

        # 4. formatting helper
        formatter = pkgs.nixpkgs-fmt;
      })
    ) //
    {
      overlays.default = overlay;
      lib = import ./default.nix { lib = (import nixpkgs { system = "x86_64-linux"; }).lib; };
    };
} 