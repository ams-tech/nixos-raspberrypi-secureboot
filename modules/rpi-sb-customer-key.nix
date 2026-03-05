# This module is meant to generate the customer key for the Raspberry Pi secure boot process.
# It is not meant to be used directly, but rather as a helper for the rpi-sign-bootcode module.
{ config, lib, ... }: 
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
    #config contents
  };
}