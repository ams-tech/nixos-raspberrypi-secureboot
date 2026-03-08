{ pkgs, rpiSbCustomerKeyTest }:
{
  create-new-keypair = rpiSbCustomerKeyTest {
    name = "Test customer key is created correctly when an existing key is not provided.";
    extraRpiConfig = {};
    extraTestScript = "";
  };
  
  use-existing-private-key = rpiSbCustomerKeyTest {
    name = "Test functionality when we use an existing private key.";
    extraRpiConfig = {
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
