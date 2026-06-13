{ lib, pkgs, config, ... }: {
  config = lib.mkIf config.athena.baseConfiguration {
    # If change kernel, remember to run 'sudo nixos-rebuild boot' and 'sudo reboot'
    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages; # LTS Kernel
      kernelModules = [ "rtl8821cu" ];
      # os-prober works wherever GRUB does; if systemd-boot is used instead this is a no-op.
      loader.grub.useOSProber = true;
      # The vmware kernel module is for running VMware Workstation *on* Athena — x86_64 only.
      extraModulePackages = lib.optionals pkgs.hostPlatform.isx86_64 (with config.boot.kernelPackages; [ vmware ]);
    };
  };
}
