self: super: { 
  rpi-sign-bootcode = (
    super.callPackage ../pkgs/rpi-sign-bootcode.nix {}
  );
}