## Runnng Tests

Use `nix flake check -L`.  The `-L` flag is necessary to get useful outputs.

## Notes:

* [rpi-sb-bootstrab.sh](https://github.com/raspberrypi/rpi-sb-provisioner/blob/bd49c37e2ee4d408793d83c0ef89b4872f567bfb/service/rpi-sb-bootstrap.sh#L455) seems to come really close to doing what we're attempting to do here.  That utility seems to do a lot of the heavy lifting WRT signing bootcode.bin, the bootloader configuration, and packaging them into pieeprom.bin.  Howerver, it may only install to devices connected over USB. To bootstrap the infrastructure, we want to allow a device to self-provision.
   * In order to deploy future updates remotely, we're going to need:
      * the ability for an rpi to update its own pieeprom.bin
      * the ability to deploy a signed pieeprom.bin as a nixpkg
   * In order to bootstrap an initial device:
      * Some "untrusted" device is going to need to sign the first bootloader
      * We have to reasonably trust a new-in-box RPi
   * Therefor, it reasonably follows that:
     * The first device in the secure ecosystem is going to need to provision itself
     * That device needs a method to attest to other devices
   * A straightforward means to that end, utilizing all of our requirements & sane practices:
      * Create a special provisioning image, getting distributed consensus from several builders
      * Burn that image into an SD card & boot an rpi with it
      * Generate a random key
         * We need to be super, extra serious about generating randomness in this context
      * Sign the RPI secure boot media with this key
      * Publish the signed secure boot media
      * Encrypt our random signing key to a yubikey using `sops-nix`
         * Clearly label & secure the yubikey
      * Publish the encrypted secret for future use

* Using common fleets of hardwre should allow one to further validate hardware.
   * Send similar "challenge" workflows to random units; allow them to attest to one anohter using software instrumentation.




## nixosModules

NixOS modules allow us to (among other things) configure services to run on a NixOS system.  

### rpi-customer-sign-bootloader

Breaking it down from the [QSG](https://github.com/raspberrypi/usbboot/tree/master/secure-boot-example)'s [sign.sh](https://github.com/raspberrypi/usbboot/blob/master/secure-boot-example/sign.sh#L20C1-L26C23) script, the command is:

```bash
   rpi-sign-bootcode \
      -c 2712 \ # this indicates the rpi5's processor
      -i "bootfiles.bin" \ # RPi signed bootcode file to be signed with the customer key
      -o "bootfiles.bin.signed" \ # The output file signed by our customer key.
      -n 16 \ # A number bundled into the firmware signing.  I believe "16" indicates we're using the customer private key.  This corresponds to the "key_id" field here: https://github.com/raspberrypi/usbboot/blob/master/docs/secure-boot-chain-of-trust-2712.pdf  
      -v 0 \ # Custom firmware version to set.  Incrementing this prevents prevents rollback to a previous version.  Must be between 0-31
      -k "${KEY_FILE}" # The customer key -- RSA2048
```

This is only suitable for signing bootcode with the customer key.

The naming of these files seems wildly inconsidtent between repositories & files, but I've decoded (read: assuming) the following:

* `bootcode5.bin` and `bootcode.bin`, in our context, are synonomous with `recovery.bin`

### pack-eeprom-image

### sign-bootimg

This was also pulled from the QSG:

rpi-eeprom-digest -i boot.img -o boot.sig -k "${KEY_FILE}"

## packages 

### rpi-sign-bootcode

This util is part of the [rpi-eeprom](https://github.com/raspberrypi/rpi-eeprom/blob/master/tools/rpi-sign-bootcode) repository.  It is a python script that signs the EEPROM second-stage bootloader image.

`nix run .#rpi-sign-bootcode`

### bootcode.bin

~~For rpi-5, we get the bootloader from [here](https://github.com/raspberrypi/rpi-eeprom/tree/master/firmware-2712/latest)~~

^ is the final bundle. look elsewhere for `bootcode5.bin`