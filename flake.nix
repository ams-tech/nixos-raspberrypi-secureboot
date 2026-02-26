{
  description = "Secure Boot Utilities for Raspberry Pi Systems";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }: 
  {
    overlays = {
      pkgs = import ./overlays/pkgs.nix;
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.pkgs ];
      };
    in {
      # packages.default = pkgs.hello;
      # devShells.default = pkgs.mkShell { buildInputs = [ pkgs.hello ]; };
      apps.rpi-sign-bootcode = flake-utils.lib.mkApp {drv = pkgs.rpi-sign-bootcode;};
    }
  );
}
