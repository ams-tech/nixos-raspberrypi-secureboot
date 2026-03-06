{ lib, testers }:
testers.runNixOSTest {
  name = "Test customer key is created correctly when an existing key is not provided.";
  
  # `nodes` define the VMs we spin up as part of this test.
  nodes = {
    # Our mock raspberry pi, which does not have an existing key provided.
    raspberryPi = 
      { pkgs, ... }:
      {
        imports = [ ../../modules/rpi-sb-customer-key.nix ];  # Import our module to generate the customer key
        services.rpiSbCustomerKey = 
        {
          enable = true;
        };
        environment.systemPackages = [ pkgs.openssl ];
      };
  };

  # `testScript` is a Python script using unittest-like statements.
  # See the docs here: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests is close
  testScript = ''
    start_all()
    raspberryPi.wait_for_unit("rpi-sb-customer-key.service")  # Wait for our service to run, which creates the key

    # Check that the private key is 2048 bits long
    raspberryPi.succeed("openssl rsa -in /var/lib/rpi-sb-customer-key/rpi-sb-customer-private-key -text -noout | grep 'Private-Key: (2048 bit'")
    # Check that we have a public key matching the private key.
    raspberryPi.succeed("openssl rsa -in /var/lib/rpi-sb-customer-key/rpi-sb-customer-private-key -pubout | grep -qf /var/lib/rpi-sb-customer-key/rpi-sb-customer-public-key")
  '';
}
