# This module is meant to generate the customer key for the Raspberry Pi secure boot process.
# It is not meant to be used directly, but rather as a helper for the rpi-sign-bootcode module.
{ config, lib, pkgs, ... }: 
let
cfg = config.services.rpiSbCustomerKey; # This is how we access the configuration options for our module, which are defined in `options` below. The user will set these options in their nixOS configuration, and we can use them to customize the behavior of our module.
in
{
  options = {
    services.rpiSbCustomerKey.enable = lib.mkEnableOption "Enable rpiSbCustomerKey module"; 
    # This defines a configuration option `services.rpiSbCustomerKey.enable` that the user can set to true to enable our module. We can then check this option in our `config` to conditionally include the logic for generating the customer key.
    # Note that this does not necessarily imply the systemd service is "enabled" -- this just enables the module in nixOS.
  };

  config = lib.mkIf cfg.enable {
    systemd.services."rpi-sb-customer-key" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      serviceConfig = {
        User = "rpi-sb-customer-key";
        WorkingDirectory = "/var/lib/rpi-sb-customer-key";
        RequiresMountsFor = "/var/lib/rpi-sb-customer-key";
        Type="oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.openssl}/bin/openssl version
          ${pkgs.openssl}/bin/openssl genrsa 2048 > /var/lib/rpi-sb-customer-key/rpi-sb-customer-private-key
          ${pkgs.openssl}/bin/openssl rsa -in rpi-sb-customer-private-key -pubout > /var/lib/rpi-sb-customer-key/rpi-sb-customer-public-key
        '';
      };
    };

    users.users.rpi-sb-customer-key = {
      home = "/var/lib/rpi-sb-customer-key";
      createHome = true;
      isSystemUser = true;
      group = "rpi-sb-customer-key";
    };
    users.groups.rpi-sb-customer-key = { };
  };
}