{pkgs, ...}:
let
  # This is the base attribute set for our "rpi-sb-customer-keygen" tests.
  rpiSbCustomerKeyTest = {name, extraRpiConfig, extraTestScript}: pkgs.testers.runNixOSTest {
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
    # `testScript` is a Python script using unittest-like statements.
    # See the docs here: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests is close
    testScript = ''
      start_all()
      raspberryPi.wait_for_unit("default.target")  # Wait for our service to run, which creates the key
      # Check that the private key is 2048 bits long
      raspberryPi.succeed("openssl rsa -in /run/rpi-sb-customer-key/rpi-sb-customer-private-key -text -noout | grep 'Private-Key: (2048 bit'")
      # Check that we have a public key matching the private key.
      raspberryPi.succeed("openssl rsa -in /run/rpi-sb-customer-key/rpi-sb-customer-private-key -pubout | grep -qf /run/rpi-sb-customer-key/rpi-sb-customer-public-key")
     '' + extraTestScript;
  };
in
import ./rpi-sb-customer-key-tests/none.nix {inherit pkgs; inherit rpiSbCustomerKeyTest;} //
import ./rpi-sb-customer-key-tests/sops-nix.nix {inherit pkgs; inherit rpiSbCustomerKeyTest;} 
