{ pkgs }:
let
  # This is the base attribute set for our "rpi-sb-customer-keygen" tests.
  generateKeyTest = name: extraConfig: pkgs.testers.runNixOSTest {
    name = name;
    # `nodes` define the VMs we spin up as part of this test.
    nodes = {
      # Our mock raspberry pi, which does not have an existing key provided.
      raspberryPi = 
        { pkgs, ... }:
        {
          imports = [ 
            ../../modules/rpi-sb-customer-key.nix 
            extraConfig
            ];  # Import our module to generate the customer key
          services.rpiSbCustomerKey = 
          {
            enable = true;
          };
          # Since we're only testing the "rpi-sb-customer-keygen" service, disable the top-level service.
          systemd.services."rpi-sb-customer-key".enable = false;
          systemd.services."rpi-sb-customer-keygen".enable = true;
          environment.systemPackages = [ pkgs.openssl ];
        };
    };
    # `testScript` is a Python script using unittest-like statements.
    # See the docs here: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests is close
    testScript = ''
      start_all()
      raspberryPi.wait_for_unit("rpi-sb-customer-keygen.service")  # Wait for our service to run, which creates the key
      # Check that the private key is 2048 bits long
      raspberryPi.succeed("openssl rsa -in /var/lib/rpi-sb-customer-key/rpi-sb-customer-private-key -text -noout | grep 'Private-Key: (2048 bit'")
      # Check that we have a public key matching the private key.
      raspberryPi.succeed("openssl rsa -in /var/lib/rpi-sb-customer-key/rpi-sb-customer-private-key -pubout | grep -qf /var/lib/rpi-sb-customer-key/rpi-sb-customer-public-key")
    '';
  };
in
{
  create-new-key = generateKeyTest "Test customer key is created correctly when an existing key is not provided." {};
  do-not-overwrite-existing-key = generateKeyTest "Test that an existing customer key is not overwritten." {
    services.rpiSbCustomerKey.enable = false;
  };
}
