# GTK & QT theme configuration
{
  config,
  pkgs,
  lib,
  ...
}: {
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
      package = pkgs.vimix-icon-theme;
      name = "Vimix";
    };

    font = {name = config.stylix.fonts.serif.name;};

    gtk3.extraConfig = {gtk-application-prefer-dark-theme = 1;};

    gtk4.extraConfig = {gtk-application-prefer-dark-theme = 1;};
  };
}
