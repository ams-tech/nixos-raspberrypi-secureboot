{ pkgs, rpiSbCustomerKeyTest }:
let
  rpiSbCustomerKeySopsNixTest = {name, extraRpiConfig, testScript}: rpiSbCustomerKeyTest {
    inherit name;
    inherit testScript;
    extraRpiConfig = extraRpiConfig // {
      services.rpiSbCustomerKey = 
      {
        secretsProvider = "sops-nix";
      };
    };
  };
in
{
  sops-nix-no-configuration = rpiSbCustomerKeySopsNixTest {
    name = "No sops-nix configuration results in service failing";
    extraRpiConfig = {};
    testScript = ''
      start_all()
      with t.assertRaises(AssertionError):
        raspberryPi.wait_for_unit("rpi-sb-customer-key-sops-nix.service") 
    '';
  };
}
