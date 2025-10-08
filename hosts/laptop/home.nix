{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: {
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
    ../../home/programs/anyrun
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
    ../../home/programs/winapps
    # ../../home/programs/heroic

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
    # REMOVE this custom shell import if using Caelestia flake module:
    # ../../home/system/shell

    # Import the Caelestia Home Manager module from your flake input!
    # inputs.caelestia-shell.homeManagerModules.default

    ./secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    packages = with pkgs; [
      # Apps
      webcord # Chat
      bitwarden # Password manager
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
      # Caelestia shell package is NOT required here if using the module,
      # but you can still add it manually if you want:
      # inputs.caelestia-shell.packages.${pkgs.system}.default
    ];
    file.".face.icon" = {source = ./profile_picture.png;};
    stateVersion = "24.05";
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };
  waybar.enable = true;
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
    package = inputs.nix-index-database.packages.${pkgs.system}.nix-index-with-small-db;
  };
  theming.enable = true;
  swaync.enable = true;
  hyprland = {
    enable = true;
    hyprpaper = true;
    mpvpaper = false;
    wlogout = true;
  };
  nixpkgs.overlays = lib.mkForce null; # fix evaluation warning about nixpkgs.overlays
  programs.home-manager.enable = true;

  # programs.caelestia = {
  #   enable = true;
  #   systemd = {
  #     enable = true; # if you prefer starting from your compositor
  #     target = "graphical-session.target";
  #     environment = [];
  #   };
  #   settings = {
  #     bar.status = {
  #       showBattery = true;
  #     };
  #     services = {
  #       useFahrenheit = false;
  #     };
  #     paths.wallpaperDir = "~/Images";
  #   };
  #   cli = {
  #     enable = true; # Also add caelestia-cli to path
  #     settings = {
  #       theme.enableGtk = false;
  #     };
  #   };
  # };
}
