{ lib, config, ... }: {
  config = lib.mkIf config.athena.baseConfiguration {
    # To not change upstream! It is managed by the installer
    services = {
      spice-vdagentd.enable = lib.mkDefault false;
      qemuGuest.enable = lib.mkDefault false;
      xe-guest-utilities.enable = lib.mkDefault false;
    };

    virtualisation = {
      # open-vm-tools supports both x86_64 and aarch64 Linux (VMware Fusion on Apple Silicon
      # runs aarch64 guests), so no architecture guard is needed here.
      vmware.guest.enable = lib.mkDefault true;
      hypervGuest.enable = lib.mkDefault false;
      # The VirtualBox guest additions rely on an out-of-tree kernel module
      # which lags behind kernel releases, potentially causing broken builds.
      virtualbox.guest.enable = lib.mkDefault false;
    };
  };
}
