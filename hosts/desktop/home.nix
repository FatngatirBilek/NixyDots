{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  quickshell = inputs.quickshell;
in {
  imports = [
    ./variables.nix

    # Programs
    ../../home/programs/kitty
    ../../home/programs/nvim
    ../../home/programs/zsh
    ../../home/programs/fetch
    ../../home/programs/git
    ../../home/programs/spicetify
    ../../home/programs/fastfetch
    # ../../home/programs/nextcloud
    ../../home/programs/yazi
    ../../home/programs/markdown
    # ../../home/programs/thunar
    ../../home/programs/lazygit
    ../../home/programs/nh
    ../../home/programs/zen
    ../../home/programs/ghostty
    ../../home/programs/nwg-dock
    ../../home/programs/zed
    ../../home/programs/wezterm
    ../../home/programs/obs

    # Scripts
    ../../home/scripts # All scripts

    # System (Desktop environment like stuff)
    ../../home/system/hyprland
    ../../home/system/hypridle
    ../../home/system/hyprlock
    ../../home/system/theming
    ../../home/system/batsignal
    ../../home/system/zathura
    ../../home/system/mime
    ../../home/system/udiskie
    ../../home/system/clipman
    ../../home/system/waybar
    ../../home/system/swaync
    ../../home/system/wofi

    inputs.niri.homeModules.niri
    ../../home/system/niri
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri

    # REMOVE this custom shell import if using Caelestia flake module:
    # ../../home/system/shell

    ../../hosts/laptop/secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    packages = with pkgs; [
      # Apps
      webcord # Chat
      bitwarden-desktop # Password manager
      vlc # Video player
      blanket # White-noise app
      firefox
      nchat
      # Dev
      go
      obsidian
      # zed-editor
      nodejs
      # python3Full
      jq
      figlet
      just

      # Utils
      zip
      unzip
      optipng
      pfetch
      pandoc
      rar
      bottom
      btop
      nautilus
      pavucontrol
      nwg-look
      networkmanagerapplet
      imagemagick
      ffmpeg-full
      nv-codec-headers
      tree
      kmon
      termtosvg
      pciutils

      # quickemu
      gnome-disk-utility
      gnumake
      cargo
      ghc
      opam
      nix-output-monitor
      nvd
      woeusb
      ntfs3g
      unetbootin
      # zed-editor
      # Just cool
      peaclock
      cbonsai
      pipes
      cmatrix
      cava
      discord
      # Backup
      vscode
      gnome-tweaks
    ];
    file.".face.icon" = {source = ./profile_picture.png;};
    stateVersion = "24.05";
  };
  programs.dankMaterialShell = {
    enable = true;
    quickshell.package = quickshell.packages.${pkgs.system}.default;
    enableSystemd = true;
  };
  services.cliphist = {
    enable = true;
    allowImages = true;
  };
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
    package = inputs.nix-index-database.packages.${pkgs.system}.nix-index-with-small-db;
  };
  theming.enable = true;
  swaync.enable = false;
  hyprland = {
    enable = true;
    hyprpaper = false;
    mpvpaper = false;
    wlogout = false;
  };
  nixpkgs.overlays = lib.mkForce null; # fix evaluation warning about nixpkgs.overlays
  programs.home-manager.enable = true;
}
