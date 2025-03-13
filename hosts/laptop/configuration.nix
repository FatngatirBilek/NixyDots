{
  config,
  pkgs,
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
    ../../nixos/warp.nix
    ../../nixos/tjkt.nix
    ../../nixos/wine.nix
    ../../nixos/fcitx.nix
    ../../nixos/tabletdriver.nix
    # Choose your theme here
    ../../themes/stylix/nixy.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];
  security.wrappers.ubridge = {
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
    };
    ssh = {
      startAgent = true;
    };
    virt-manager = {
      enable = true;
    };
  };

  users.groups.libvirtd.members = ["${config.var.username}"];
  virtualisation = {
    vmware = {
      guest = {
        enable = true;
      };
      host = {
        enable = true;
        package = pkgs.vmware-workstation;
      };
    };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
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
      };
    };
  };
  services.xserver = {
    desktopManager.gnome.enable = true;
  };

  virtualisation.spiceUSBRedirection.enable = true;
  home-manager.users."${config.var.username}" = import ./home.nix;
  services.flatpak.enable = true;
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
