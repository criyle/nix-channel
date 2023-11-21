{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        packages.judge = (import ./judge.nix)
          { pkgs = nixpkgs.legacyPackages.${system}; system = system; };
      }
    );
}
