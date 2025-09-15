{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.theming;

  themerepo = pkgs.fetchFromGitHub {
    owner = "FatngatirBilek";
    repo = "themes-repo";
    rev = "main";
    sha256 = "sha256-XSflGc9CO4mmm6HDWwMFg8+DK5fPpVXdQ0HIr0tEOtU=";
  };

  mkSourcePrefix = prefix: attrs:
    builtins.listToAttrs (
      lib.mapAttrsToList (
        name: value: {
          name = "${prefix}/${name}";
          value = {source = value;};
        }
      )
      attrs
    );
in {
  options.theming = {
    enable = mkEnableOption "Enable theming stuff like cursor theme, icon theme and etc";
  };

  config = mkIf cfg.enable {
    # All theming files come from the GitHub repo!
    home.file.".themes".source = "${themerepo}/.themes";

    xdg.configFile =
      {
        "Kvantum".source = "${themerepo}/Kvantum";
        "qt5ct".source = "${themerepo}/qt5ct";
        "qt6ct".source = "${themerepo}/qt6ct";
      }
      // (mkSourcePrefix "gtk-4.0" {
        "assets" = "${themerepo}/.themes/Fluent-Dark/gtk-4.0/assets";
        "gtk.css" = "${themerepo}/.themes/Fluent-Dark/gtk-4.0/gtk.css";
        "icons" = "${themerepo}/.themes/Fluent-Dark/gtk-4.0/gtk-dark.css";
      })
      // (mkSourcePrefix "vesktop" {
        "settings" = "${themerepo}/vesktop/settings";
        "settings.json" = "${themerepo}/vesktop/settings.json";
        "themes" = "${themerepo}/vesktop/themes";
      })
      // (mkSourcePrefix "Vencord" {
        "settings" = "${themerepo}/vesktop/settings";
        "themes" = "${themerepo}/vesktop/themes";
      });

    # ... rest of your config unchanged ...
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
      platformTheme.name = "qtct";
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
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme.name = "Fluent-Dark";
      font.name = "Noto Sans Medium";
      font.size = 11;
    };

    home.sessionVariables = {
      GTK_THEME = "Fluent-Dark";
      GTK_APPLICATION_PREFER_DARK_THEME = "1";
    };
  };
}
