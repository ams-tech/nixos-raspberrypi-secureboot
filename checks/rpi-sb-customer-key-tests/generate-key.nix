{ lib, testers }:
testers.runNixOSTest {
  name = "Test customer key is created correctly when an existing key is not provided.";
  
  # `nodes` define the VMs we spin up as part of this test.
  nodes = {
    # Our mock raspberry pi, which does not have an existing key provided.
    raspberryPi = 
      { ... }:
      {

      };
  };

  # `testScript` is a Python script using unittest-like statements.
  # TODO: Find a link to the docs for this. https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests is close
  # adam@malak:~/nixos-raspberrypi-secureboot$ openssl genrsa 2048 > your_private_key.key
  # adam@malak:~/nixos-raspberrypi-secureboot$ openssl rsa -in your_private_key.key -check -noout
  testScript = ''
    start_all()
    raspberryPi.wait_for_unit("rpi-sb-customer-key.service")

    # Check that our public key exists & matches our private key
    raspberriPi.success("ssh-keygen -y -e -f /run/secrets/rpi-sb-customer-private-key |")
    raspberryPi.assert_file_exists("/run/secrets/rpi-sb-customer-private-key")
    raspberryPi.assert_file_exists("/run/rpi-sb-customer-key/rpi-sb-customer-public-key")
  '';
}
