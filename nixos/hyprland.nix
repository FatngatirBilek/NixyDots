{
  pkgs,
  lib,
  ...
}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Add hyprland portal alongside existing COSMIC portal
  xdg.portal.extraPortals = lib.mkAfter [
    pkgs.xdg-desktop-portal-hyprland
  ];

  # Per-DE portal configuration so hyprland sessions use the right backend
  xdg.portal.config.hyprland.default = ["hyprland" "gtk"];

  security.polkit.enable = true;
  services.dbus.enable = true;


  # Fonts required by the quickshell config
  fonts.packages = with pkgs; [
    eb-garamond
    nerd-fonts.monaspace
  ];

  # Hyprland binary cache
  nix.settings = {
    substituters = lib.mkAfter ["https://hyprland.cachix.org"];
    trusted-substituters = lib.mkAfter ["https://hyprland.cachix.org"];
    trusted-public-keys = lib.mkAfter [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
