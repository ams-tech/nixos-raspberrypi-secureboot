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
      
    };
  };

  # "config" parses the options and creats our module's nixOS configuration.
  config = lib.mkIf (cfg.secretsProvider == "sops-nix") {
    systemd.services."rpi-sb-customer-key-sops-nix" = {
      wantedBy = [ "rpi-sb-customer-key.service" ];
      unitConfig = {
        RequiresMountsFor = cfg.workingDirectory;
      };
      serviceConfig = {
        Type = "oneshot";
        User = cfg.username;
        Group = cfg.username;
        WorkingDirectory = cfg.workingDirectory;
        RemainAfterExit = true;
        ExecStart = ''
          /bin/sh -c "[ -f /run/secrets/rpi-sb-customer-key ] && echo 'hello'" 
        '';
      };
    };
  };
}
