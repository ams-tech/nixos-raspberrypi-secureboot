{ pkgs }:
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
            ../../modules/rpi-sb-customer-key
            extraRpiConfig
          ];
          services.rpiSbCustomerKey = 
          {
            enable = true;
            secretsProvider = "sops-nix";
          };
          environment.systemPackages = [ pkgs.openssl pkgs.coreutils ];
        };
    };
    # `testScript` is a Python script using unittest-like statements.
    # See the docs here: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests is close
    testScript = ''
      start_all()
      raspberryPi.wait_for_unit("default.target")  # Wait for our service to run, which creates the key
    '' + extraTestScript;
  };
  expectedResultsTestScript = ''
      
  '';
in
{
  create-new-keypair = rpiSbCustomerKeyTest {
    name = "Test customer key is created correctly when an existing key is not provided."; 
    extraRpiConfig = {}; 
    extraTestScript = "";
  };
}
