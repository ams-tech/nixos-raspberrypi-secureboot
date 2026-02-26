{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  python3,
}:

stdenv.mkDerivation (finalAttrs:   
  let 
    pythonDeps = python3.withPackages(pipPackage: with pipPackage;[
      # Put a list of the module's python dependencies here
      pycryptodomex
    ]);
  in{

  pname = "rpi-sign-bootcode";
  version = "2025.12.08-2712";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpi-eeprom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6zlq6BibjPWSGQPl13vFNCPVzjnROfYowVYPttQ9jZQ=";
    fetchSubmodules = true;
  };

  buildInputs = [ pythonDeps ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/tools/rpi-sign-bootcode $out/bin
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    homepage = "https://github.com/raspberrypi/rpi-eeprom";
    changelog = "https://github.com/raspberrypi/rpi-eeprom/blob/v${finalAttrs.version}/debian/changelog";
    description = "Utility to sign a Raspberry Pi EEPROM bootloader";
    mainProgram = "rpi-sign-bootcode";
    license = lib.licenses.bsd3;
    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "armv7l-linux"
      "armv6l-linux"
      "x86_64-linux"
      "x86_64-darwin"
    ];
  };
})