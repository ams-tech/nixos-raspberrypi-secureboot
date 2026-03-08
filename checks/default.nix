{pkgs, ...}:
let
  # This is the base attribute set for our "rpi-sb-customer-keygen" tests.
  rpiSbCustomerKeyTest = {name, extraRpiConfig, testScript}: pkgs.testers.runNixOSTest {
    # `testScript` is a Python script using unittest-like statements.
    # See the docs here: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests is close
    inherit testScript;
    name = name;
    # `nodes` define the VMs we spin up as part of this test.
    nodes = {
      # Our mock raspberry pi, which does not have an existing key provided.
      raspberryPi = 
        { pkgs, config, ... }:
        {
          # Import our module to generate the customer key, along with the extraRpiConfig passed to the test.
          imports = [ 
            ../modules/rpi-sb-customer-key 
            extraRpiConfig
          ];
          services.rpiSbCustomerKey = 
          {
            enable = true;
            secretsProvider = "none";
          };
          environment.systemPackages = [ pkgs.openssl pkgs.coreutils ];
        };
    };
  };
in
import ./rpi-sb-customer-key-tests/none.nix {inherit pkgs; inherit rpiSbCustomerKeyTest;} //
import ./rpi-sb-customer-key-tests/sops-nix.nix {inherit pkgs; inherit rpiSbCustomerKeyTest;} 
