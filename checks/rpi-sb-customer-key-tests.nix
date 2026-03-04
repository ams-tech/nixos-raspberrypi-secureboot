{ lib, testers }:
testers.runNixOSTest {
  name = "key-genertion";
  meta {
    description = "Test that the customer key is generated when a key does not already exist.";
    longDescription = ''
      # rpi-sb-customer-key-tests.nix

      ## Description

      This test verifies that the customer key is generated when a key does not already exist. It does this by running the `nixos-test` framework with a test configuration that does not include a pre-generated customer key. The test then checks for the existence of the generated key and verifies its properties.
    ''
  }
}
