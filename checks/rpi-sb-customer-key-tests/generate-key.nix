{ lib, testers }:
testers.runNixOSTest {
  name = "Test customer key is created correctly when an existing key is not provided.";
  
  # `nodes` define the VMs we spin up as part of this test.
  nodes = {
    # Our mock raspberry pi, which does not have an existing key provided.
    raspberryPi = 
      { ... }:
      {
        imports = [ ../../modules/rpi-sb-customer-key.nix ];  # Import our module to generate the customer key
        services.rpiSbCustomerKey = 
        {
          enable = true;
        };
      };
  };

  # `testScript` is a Python script using unittest-like statements.
  # See the docs here: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests is close
  testScript = ''
    start_all()
    raspberryPi.wait_for_unit("rpi-sb-customer-key.service")  # Wait for our service to run, which creates the key

    # Check that our public key exists & matches our private key
    raspberriPi.succeed("openssl rsa -in /run/secrets/rpi-sb-customer-private-key -check -noout")
    raspberriPi.succeed("openssl rsa -in /run/secrets/rpi-sb-customer-private-key -pubout | grep -qf /run/rpi-sb-customer-key/rpi-sb-customer-public-key")
    # Check that the private key is 2048 bits long
  '';
}
