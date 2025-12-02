{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.theming;
in {
  options.theming = {
    enable = mkEnableOption "Enable theming stuff like cursor theme, icon theme and etc";
  };

  config = mkIf cfg.enable {
    qt = {
      enable = true;
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    gtk = {
      enable = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      cursorTheme = {
        name = "Bibata-Modern-Ice";
        size = 24;
      };
      iconTheme = {
        name = "WhiteSur-dark";
        package = pkgs.whitesur-icon-theme;
      };
      theme = {
        name = "Orchis-Dark";
        package = pkgs.orchis-theme;
      };
      font.name = "Noto Sans Medium";
      font.size = 11;
    };

    home.sessionVariables = {
      GTK_THEME = "Orchis-Dark";
      GTK_ICON_THEME = "WhiteSur-dark";
      GTK_CURSOR_THEME = "Bibata-Modern-Ice";
      GTK_APPLICATION_PREFER_DARK_THEME = "1";
      GTK2_RC_FILES = "${config.home.homeDirectory}/.gtkrc-2.0";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_ICON_THEME = "WhiteSur-dark";
    };
  };
}
