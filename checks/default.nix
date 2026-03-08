{pkgs, ...}:
import ./rpi-sb-customer-key-tests/rpi-sb-customer-keygen.nix {inherit pkgs;} //
import ./rpi-sb-customer-key-tests/rpi-sb-customer-key-sops-nix.nix {inherit pkgs;}
