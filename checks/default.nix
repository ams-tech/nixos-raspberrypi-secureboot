{pkgs, ...}:
import ./rpi-sb-customer-key-tests/none.nix {inherit pkgs;} //
import ./rpi-sb-customer-key-tests/sops-nix.nix {inherit pkgs;}
