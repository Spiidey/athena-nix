# NixOS installation CD with GNOME and GDM (Wayland).
{ pkgs, ... }:
{
  imports = [ ./installation-cd-graphical-base.nix ];

  isoImage.edition = "gnome";

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  # autoLogin moved out of xserver in NixOS 24.05.
  services.displayManager.autoLogin = {
    enable = true;
    user = "athena";
  };

  environment.systemPackages = [ pkgs.xdg-user-dirs ];
}
