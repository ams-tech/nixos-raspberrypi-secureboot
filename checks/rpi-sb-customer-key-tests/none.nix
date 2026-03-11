{ pkgs, rpiSbCustomerKeyTest }:
let
  rpiSbCustomerKeyNoneTest = {name, extraRpiConfig, extraTestScript}: rpiSbCustomerKeyTest {
    inherit name;
    extraRpiConfig = extraRpiConfig // {
      services.rpiSbCustomerKey = 
      {
        secretsProvider = "none";
      };
    };
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
  create-new-keypair = rpiSbCustomerKeyNoneTest {
    name = "Test customer key is created correctly when an existing key is not provided.";
    extraRpiConfig = {};
    extraTestScript = "";
  };
  
  use-existing-private-key = rpiSbCustomerKeyNoneTest {
    name = "Test functionality when we use an existing private key.";
    extraRpiConfig = {
      # Create a service to inject an existing private key before the generate key service starts
      systemd.services."rpi-sb-customer-key-test" = {
        wantedBy = [ "rpi-sb-customer-key.service" ];
        before = [ "rpi-sb-customer-key.service" ];
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
    }; 
    # Extra test script for use-existing-private-key
    extraTestScript = ''
      # Verify the previously existing key is the one we use
      raspberryPi.succeed("""
        diff /run/rpi-sb-customer-key/rpi-sb-customer-private-key /run/rpi-sb-customer-key/test-rpi-sb-customer-private-key
      """)
    '';
  };
}
