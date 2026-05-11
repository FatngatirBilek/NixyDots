{
  pkgs,
  inputs,
  lib,
  ...
}: let
  quickshellPkg = inputs.noctalia-qs.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
