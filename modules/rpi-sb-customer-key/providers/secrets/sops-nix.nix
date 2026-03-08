# This module is meant to generate the customer key for the Raspberry Pi secure boot process.
# It is not meant to be used directly, but rather as a helper for the rpi-sign-bootcode module.
{ config, lib, pkgs, ... }: 
let
  cfg = config.services.rpiSbCustomerKey; # This is how we access the configuration options for our module, which are defined in `options` below. The user will set these options in their nixOS configuration, and we can use them to customize the behavior of our module.
in
{
  # options allows consumers of this module to enable/disable it programatically & change underlying constants.
  # See https://nix.dev/tutorials/module-system/deep-dive for details.
  options = {
    # This defines a configuration option `services.rpiSbCustomerKey.enable` that the user can set to true to enable our module. We can then check this option in our `config` to conditionally include the logic for generating the customer key.
    # Note that this does not necessarily imply the systemd service is "enabled" -- this just enables the module in nixOS.
    services.rpiSbCustomerKey.sops-nix = {
      # The working directory for this module.  We default this to /run because we want it to not persist through reboots -- it's a naked private key, after all!
      workingDirectory = lib.mkOption {
        type = lib.types.path;
        default = "/run/rpi-sb-customer-key";
        description = "Working directory of this service; typically something that's NOT persistent through a reboot.";
      };
    };
  };

  # "config" parses the options and creats our module's nixOS configuration.
  config = lib.mkIf (cfg.enable.secretsProvider == "sops-nix") {
    
  };
}
