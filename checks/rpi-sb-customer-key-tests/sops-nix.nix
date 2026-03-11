{ pkgs, rpiSbCustomerKeyTest }:
let
  rpiSbCustomerKeySopsNixTest = {name, extraRpiConfig, testScript}: rpiSbCustomerKeyTest {
    inherit name;
    inherit testScript;
    extraRpiConfig = extraRpiConfig // {
      services.rpiSbCustomerKey = 
      {
        secretsProvider = "sops-nix";
      };
    };
  };
in
{
  sops-nix-no-configuration = rpiSbCustomerKeySopsNixTest {
    name = "No sops-nix configuration results in service failing";
    extraRpiConfig = {};
    testScript = ''
      start_all()
      with t.assertRaises(AssertionError):
        raspberryPi.wait_for_unit("rpi-sb-customer-key-sops-nix.service") 
    '';
  };
  sops-nix-no-secrets = rpiSbCustomerKeySopsNixTest {
    name = "A valid sops-nix configuration, but missing secrets file, results in service failing";
    extraRpiConfig = {
      services.rpiSbCustomerKey = 
      {
        secretsProvider = "sops-nix";
      };
    };
    testScript = ''
      start_all()
      with t.assertRaises(AssertionError):
        raspberryPi.wait_for_unit("rpi-sb-customer-key-sops-nix.service") 
    '';
  };
    sops-nix-invalid-secrets = rpiSbCustomerKeySopsNixTest {
    name = "A valid sops-nix configuration, but invalid secrets file, results in service failing";
    extraRpiConfig = {
      services.rpiSbCustomerKey = 
      {
        secretsProvider = "sops-nix";
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
            WorkingDirectory = "/var/lib/rpi-sb-customer-key";
            RemainAfterExit = true;
            ExecStartPre = ''
              /bin/sh -c "${pkgs.coreutils}/bin/mkdir -p /var/lib/rpi-sb-customer-key/" 
              '';
            ExecStart = ''
              /bin/sh -c "${pkgs.coreutils}/bin/echo 'invalid secrets file' > /var/lib/rpi-sb-customer-key/secrets.yaml" 
              '';
          };
        };
      };
    };
    testScript = ''
      start_all()
      with t.assertRaises(AssertionError):
        raspberryPi.wait_for_unit("rpi-sb-customer-key-sops-nix.service") 
    '';
  };
}
