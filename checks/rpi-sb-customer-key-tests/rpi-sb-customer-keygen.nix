{ pkgs }:
let
  # This is the base attribute set for our "rpi-sb-customer-keygen" tests.
  generateKeyTest = name: extraRpiConfig: extraTestScript: pkgs.testers.runNixOSTest {
    name = name;
    # `nodes` define the VMs we spin up as part of this test.
    nodes = {
      # Our mock raspberry pi, which does not have an existing key provided.
      raspberryPi = 
        { pkgs, config, ... }:
        {
          # Import our module to generate the customer key, along with the extraRpiConfig passed to the test.
          imports = [ 
            ../../modules/rpi-sb-customer-key.nix 
            extraRpiConfig
          ];
          services.rpiSbCustomerKey = 
          {
            enable = true;
          };
          # Since we're only testing the "rpi-sb-customer-keygen" service, disable the top-level service.
          systemd.services."rpi-sb-customer-key".enable = false;
          systemd.services."rpi-sb-customer-keygen".wantedBy = [ "default.target" ];
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
{
  create-new-keypair = generateKeyTest "Test customer key is created correctly when an existing key is not provided." {} "";
  
  use-existing-private-key = generateKeyTest "Test functionality when we use an existing private key." {
    # Create a service to inject an existing private key before the generate key service starts
    systemd.services."rpi-sb-customer-keygen-test" = {
      wantedBy = [ "rpi-sb-customer-keygen.service" ];
      before = [ "rpi-sb-customer-keygen.service" ];
      unitConfig = {
        RequiresMountsFor = "/run/rpi-sb-customer-key";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "rpi-sb-customer-key";
        Group = "rpi-sb-customer-key";
        WorkingDirectory = "/run/rpi-sb-customer-key";
        RemainAfterExit = true;
        ExecStart = ''
          /bin/sh -c "${pkgs.openssl}/bin/openssl genrsa 2048 > rpi-sb-customer-private-key && ${pkgs.coreutils}/bin/cp rpi-sb-customer-private-key test-rpi-sb-customer-private-key" 
          '';
      };
    };
  } 
  # Extra test script for use-existing-private-key
  ''
    # Verify the previously existing key is the one we use
    raspberryPi.succeed("""
      diff /run/rpi-sb-customer-key/rpi-sb-customer-private-key /run/rpi-sb-customer-key/test-rpi-sb-customer-private-key
    """)
  ''
  ;
}
