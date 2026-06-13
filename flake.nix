{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      username = "athena";
      theme = "temple";
      desktop = "gnome";
      dmanager = "sddm";
      mainShell = "fish";
      terminal = "kitty";
      browser = "firefox";
      bootloader = if builtins.pathExists "/sys/firmware/efi" then "systemd" else "grub";

      mkSystem = system: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ lib, pkgs, config, ...}: let
              hostname = "athenaos";
              hashed = "$6$zjvJDfGSC93t8SIW$AHhNB.vDDPMoiZEG3Mv6UYvgUY6eya2UY5E2XA1lF7mOg6nHXUaaBmJYAMMQhvQcA54HJSLdkJ/zdy8UKX3xL1";
              hashedRoot = "$6$zjvJDfGSC93t8SIW$AHhNB.vDDPMoiZEG3Mv6UYvgUY6eya2UY5E2XA1lF7mOg6nHXUaaBmJYAMMQhvQcA54HJSLdkJ/zdy8UKX3xL1";
            in {
              networking.hostName = "${hostname}";
              users = lib.mkIf config.athena.enable {
                mutableUsers = false;
                extraUsers.root.hashedPassword = "${hashedRoot}";
                users.${config.athena.homeManagerUser} = {
                  shell = pkgs.${config.athena.mainShell};
                  isNormalUser = true;
                  hashedPassword = "${hashed}";
                  extraGroups = [ "wheel" "input" "video" "render" "networkmanager" ];
                };
              };
            })
          ] ++ extraModules;
        };

      liveImageModules = [
        home-manager.nixosModules.home-manager
        ./nixos
        {
          athena = {
            enable = true;
            baseHosts = true;
            baseLocale = true;
            homeManagerUser = "athena";
            desktopManager = "mate";
            displayManager = null; # ISO uses lightdm directly via installation-cd-graphical-mate.nix
            terminal = "alacritty";
            theme = "graphite";
          };
        }
      ];
    in {
      nixosConfigurations = {
        # nix build .#nixosConfigurations.live-image.config.system.build.isoImage
        "live-image" = mkSystem "x86_64-linux" ([ ./nixos/installation/iso.nix ] ++ liveImageModules);

        # nix build .#packages.aarch64-linux.live-image
        "live-image-aarch64" = mkSystem "aarch64-linux" ([ ./nixos/installation/iso.nix ] ++ liveImageModules);

        "runtime" = mkSystem "x86_64-linux" [
          "/etc/nixos/hardware-configuration.nix"
          home-manager.nixosModules.home-manager
          ./nixos
          {
            athena = {
              inherit bootloader terminal theme mainShell browser;
              enable = true;
              baseConfiguration = true;
              baseSoftware = true;
              baseLocale = true;
              homeManagerUser = username;
              desktopManager = desktop;
              displayManager = dmanager;
            };
          }
        ];

        "student" = mkSystem "x86_64-linux" [
          "/etc/nixos/hardware-configuration.nix"
          ./nixos/modules/roles/student
        ];
      };

      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
        "live-image" = self.nixosConfigurations.${
          if system == "aarch64-linux" then "live-image-aarch64" else "live-image"
        }.config.system.build.isoImage;
        "aegis-nix" = pkgs.callPackage ./nixos/pkgs/aegis-nix/package.nix {};
        "dory" = pkgs.callPackage ./nixos/pkgs/dory/package.nix {};
        default = self.packages.${system}."live-image";
      });

      nixosModules = rec {
        athena = ./nixos;
        default = athena;
      };
    };
}
