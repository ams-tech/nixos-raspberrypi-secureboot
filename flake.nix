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
    in 
    {
      # nixosModules = {
      #   rpi-sign-bootcode = { config, lib, pkgs, ... }: import ./modules/rpi-sign-bootcode.nix {
      #     inherit config lib pkgs;
      #  };
      # };
      
      # Packages are the actual binaries & other artifacts that can be used by users and nixOSModules. They are meant to be installed in the system or used in development environments.
      packages = {
        default = pkgs.rpi-sign-bootcode;
        rpi-sign-bootcode = pkgs.rpi-sign-bootcode;
      };

      # Checks are the automated tests for our flake.
      checks = import ./checks {};
    }
  );
}
