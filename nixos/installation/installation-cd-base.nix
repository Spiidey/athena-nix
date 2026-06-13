# This module contains the basic configuration for building a NixOS
# installation CD.

{ config, lib, options, pkgs, modulesPath, ... }:

with lib;

{
  imports =
    [ "${modulesPath}/installer/cd-dvd/iso-image.nix"

      # Profiles of this basic installation CD.
      "${modulesPath}/profiles/all-hardware.nix"
      "${modulesPath}/profiles/base.nix"
      ./installation-device.nix
    ];

  # Adds terminus_font for people with HiDPI displays
  console.packages = options.console.packages.default ++ [ pkgs.terminus_font ];

  # Override baseName so the ISO file is named athenaos-... instead of nixos-...
  # image.baseName drives both the on-disk filename and the store-path name;
  # mkForce is needed because iso-image.nix sets it at normal priority.
  image.baseName = mkForce "athenaos-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";

  # EFI booting
  isoImage.makeEfiBootable = true;

  # USB booting
  isoImage.makeUsbBootable = true;

  # Add Memtest86+ to the CD (x86 only — not available on aarch64).
  boot.loader.grub.memtest86.enable = mkDefault pkgs.stdenv.hostPlatform.isx86;

  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = mkImageMediaOverride [ ];
  fileSystems = mkImageMediaOverride config.lib.isoFileSystems;

  boot.postBootCommands = ''
    for o in $(</proc/cmdline); do
      case "$o" in
        live.athena.passwd=*)
          set -- $(IFS==; echo $o)
          echo "athena:$2" | ${pkgs.shadow}/bin/chpasswd
          ;;
      esac
    done
  '';

  system.stateVersion = lib.mkDefault "25.11";
}
