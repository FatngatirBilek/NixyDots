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
    xdg.configFile = {
      "Kvantum".source = "${pkgs.whitesur-gtk-theme}/share/themes/WhiteSur-Dark/Kvantum";
      "qt5ct".source = "${pkgs.whitesur-gtk-theme}/share/themes/WhiteSur-Dark/qt5ct";
      "qt6ct".source = "${pkgs.whitesur-gtk-theme}/share/themes/WhiteSur-Dark/qt6ct";
    };

    xdg.desktopEntries.discord.settings = {
      Exec = "discord --ozone-platform-hint=auto %U";
      Categories = "Network;InstantMessaging;Chat";
      GenericName = "All-in-one cross-platform voice and text chat for gamers";
      Icon = "discord";
      MimeType = "x-scheme-handler/discord";
      Keywords = "discord;vencord;electron;chat";
      Name = "Discord";
      StartupWMClass = "discord";
      Type = "Application";
    };

    dconf.settings = {
      "org/nemo/preferences" = {
        default-folder-viewer = "list-view";
        show-hidden-files = true;
        thumbnail-limit = lib.hm.gvariant.mkUint64 68719476736;
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        migrated-gtk-settings = true;
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

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
      cursorTheme = lib.mkForce {
        name = "Bibata-Modern-Ice";
        size = 22;
      };
      iconTheme = {
        name = "WhiteSur-dark";
        package = pkgs.whitesur-icon-theme;
      };
      theme = {
        name = "WhiteSur-Dark";
        package = pkgs.whitesur-gtk-theme;
      };
      font.name = "Noto Sans Medium";
      font.size = 11;
    };

    home.sessionVariables = {
      GTK_THEME = "WhiteSur-Dark";
      GTK_APPLICATION_PREFER_DARK_THEME = "1";
    };
  };
}
