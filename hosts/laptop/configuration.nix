{ config, pkgs, ... }:
let
  acermodule = config.boot.kernelPackages.callPackage ../../nixos/acer-module.nix {};
in {  
  environment.systemPackages = with pkgs; [
    # Enables v4l2loopback GUI utilities.
    v4l-utils
  ];
  imports = [
    ../../nixos/nvidia.nix # CHANGEME: Remove this line if you don't have an Nvidia GPU
    ../../nixos/prime.nix # CHANGEME: Remove this line if you don't have an Nvidia GPU

    ../../nixos/audio.nix
    ../../nixos/auto-upgrade.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/network-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/timezone.nix
    ../../nixos/tuigreet.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/xdg-portal.nix
    ../../nixos/variables-config.nix
    ../../nixos/docker.nix
    ../../nixos/pia.nix
    ../../nixos/tjkt.nix
   # ../../nixos/wine.nix
      # Choose your theme here
    ../../themes/stylix/nixy.nix

    ./hardware-configuration.nix
    ./variables.nix
    
  ];

  time.hardwareClockInLocalTime = true;
  programs.ssh.startAgent = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  home-manager.users."${config.var.username}" = import ./home.nix;
  services.flatpak.enable = true;
  boot.extraModulePackages = [ 
    acermodule 
    config.boot.kernelPackages.v4l2loopback
    ];
  boot.kernelModules = [ "facer" "wmi" "sparse-keymap" "video" "v4l2loopback" ];
 
  # Don't touch this
  system.stateVersion = "24.05";
}
