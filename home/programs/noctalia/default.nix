{
  pkgs,
  inputs,
  lib,
  ...
}: let
  quickshellPkg = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  noctaliaPkg = pkgs.callPackage ./nix/package.nix {
    version = "local";
    quickshell = quickshellPkg;
  };
in {
  imports = [
    ./nix/home-module.nix
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    package = noctaliaPkg;
  };

  # ── Elephant launcher backend ─────────────────────────────────────────────────
  programs.elephant = {
    enable = true;
    installService = true;
    debug = false;

    providers = [
      "desktopapplications"
      "files"
      "clipboard"
      "runner"
      "calc"
      "websearch"
      "windows"
    ];
  };

  xdg.configFile."elephant/wallpaper.toml".text = ''
    set_command = "hyprctl hyprpaper wallpaper ',%FILE%'"
  '';

  # Keep previous utility dependencies
  home.packages = with pkgs; [
    brightnessctl
    cava
    ddcutil
    lm_sensors
    playerctl
    grim
    swappy
    libqalculate
    networkmanager
    wlsunset
    bluez
    bluez-tools
    jq
    curl
    zenity
  ];
}
