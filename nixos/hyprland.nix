{
  pkgs,
  lib,
  ...
}: {
  programs.hyprland = {
    enable = true;
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

  # PAM service for Quickshell's lock screen.
  # LockContext.qml uses PamContext with config: "quickshell-lock".
  # Without this entry /etc/pam.d/quickshell-lock doesn't exist and
  # pam.start() errors immediately — making Enter do nothing on the lock screen.
  security.pam.services.quickshell-lock = {
    text = ''
      auth      include   login
      account   include   login
      password  include   login
      session   include   login
    '';
  };

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
