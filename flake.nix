{
  description = "Secure Boot Utilities for Raspberry Pi Systems";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system};
    in {
      overlays = {
        pkgs = import ./overlays/pkgs.nix;
      }
      # packages.default = pkgs.hello;
      # devShells.default = pkgs.mkShell { buildInputs = [ pkgs.hello ]; };
    }
  );
}
