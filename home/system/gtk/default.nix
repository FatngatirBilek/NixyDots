# GTK & QT theme configuration
{
  config,
  pkgs,
  lib,
  ...
}: let
  accent = "#${config.lib.stylix.colors.base0D}";
  foreground = "#${config.lib.stylix.colors.base05}";
  background = "#${config.lib.stylix.colors.base00}";
  background-alt = "#${config.lib.stylix.colors.base01}";

  c0 = "#${config.lib.stylix.colors.base00}";
  c1 = "#${config.lib.stylix.colors.base08}";
  c2 = "#${config.lib.stylix.colors.base0B}";
  c3 = "#${config.lib.stylix.colors.base0A}";
  c4 = "#${config.lib.stylix.colors.base0D}";
  c5 = "#${config.lib.stylix.colors.base0E}";
  c6 = "#${config.lib.stylix.colors.base0C}";
  c7 = "#${config.lib.stylix.colors.base05}";
  c8 = "#${config.lib.stylix.colors.base03}";
  c9 = "#${config.lib.stylix.colors.base08}";
  c10 = "#${config.lib.stylix.colors.base0B}";
  c11 = "#${config.lib.stylix.colors.base0A}";
  c12 = "#${config.lib.stylix.colors.base0D}";
  c13 = "#${config.lib.stylix.colors.base0E}";
  c14 = "#${config.lib.stylix.colors.base0C}";
  c15 = "#${config.lib.stylix.colors.base07}";
in {
  #  qt =  {
  #   enable = true;
  #    platformTheme.name = "gtk2";
  #    style.name = "gtk2";
  #  };

  gtk = {
    enable = true;
    cursorTheme = lib.mkForce {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 22;
    };
    theme = lib.mkForce {
      package = pkgs.orchis-theme;
      name = "Orchis";
    };

    iconTheme = {
      package = pkgs.tela-icon-theme;
      name = "Tela";
    };

    font = {name = config.stylix.fonts.serif.name;};

    gtk3.extraConfig = {gtk-application-prefer-dark-theme = 1;};

    gtk4.extraConfig = {gtk-application-prefer-dark-theme = 1;};
  };
}
