{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  acermodule =
    config.boot.kernelPackages.callPackage ../../nixos/acer-module.nix {};
in {
  environment.systemPackages = with pkgs; [
    # Enables v4l2loopback GUI utilities.
    v4l-utils
  ];
  imports = [
    ../../nixos/nvidia.nix # CHANGEME: Remove this line if you don't have an Nvidia GPU
    ../../nixos/intel.nix # CHANGEME: Remove this line if you don't have an Intel GPU
    ../../nixos/prime.nix # Prime

    ../../nixos/audio.nix
    ../../nixos/auto-upgrade.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/network-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/timezone.nix
    # ../../nixos/tuigreet.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/variables-config.nix
    ../../nixos/docker.nix
    ../../nixos/warp.nix
    ../../nixos/tjkt.nix
    ../../nixos/wine.nix
    ../../nixos/fcitx.nix
    ../../nixos/overrides.nix
    # ../../nixos/tabletdriver.nix
    ../../nixos/greeter.nix
    ../../nixos/lanzaboote.nix # Secure boot
    ../../nixos/games.nix
    # ../../nixos/packettracer.nix
    # ../../nixos/ollama.nix
    ./hardware-configuration.nix
    ./variables.nix
  ];
  security.wrappers.ubridge = {
    # something for gns3
    source = "/run/current-system/sw/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+rx,o+rx";
  };
  users.groups.ubridge = {};
  time.hardwareClockInLocalTime = true;
  # nixpkgs.overlays = [
  #   # temporary fix for broken symlinks
  #   (final: prev: {
  #     vimix-icon-theme = prev.vimix-icon-theme.overrideAttrs (oldAttrs: {
  #       dontCheckForBrokenSymlinks = true;
  #     });
  #   })
  # ];
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        icu
      ];
    };
    /*
       ssh = {
      startAgent = true;
    };
    */

    virt-manager = {
      enable = true;
    };
  };
  # users.extraGroups.vboxusers.members = ["${config.var.username}"];
  users.groups.libvirtd.members = ["${config.var.username}"];
  virtualisation = {
    waydroid.enable = true;
    # virtualbox = {
    #   host.enable = true;
    # };
    vmware.host.enable = true;
    vmware.guest.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        /*
           ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            })
            .fd
          ];
        };
        */
      };
    };
  };
  # kde connect
  programs.kdeconnect.enable = true;

  # local send
  programs.localsend.enable = true;

  # Cosmic Trouble
  # services.displayManager.cosmic-greeter.enable = true;
  # environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
  # services.desktopManager.cosmic.enable = false;
  home-manager.users."${config.var.username}" = import ./home.nix;
  services.flatpak.enable = true;

  # Game
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  boot.extraModulePackages = [
    acermodule
    config.boot.kernelPackages.v4l2loopback
  ];
  boot.kernelModules = [
    "facer"
    "wmi"
    "sparse-keymap"
    "video"
    "v4l2loopback"
  ];

  # Don't touch this
  system.stateVersion = "24.05";
}
