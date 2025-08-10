{
  config,
  pkgs,
  lib,
  ...
}: let
  caelestiaShellSrc = pkgs.fetchFromGitHub {
    owner = "caelestia-dots";
    repo = "shell";
    rev = "main"; # Or pin to a commit hash for reproducibility
    sha256 = "sha256-ZED+pxtqG/zAMdRIzW0dFfG47u0+hEZmI1EzJy2dKBg=";
  };
in {
  # Configuration files
  xdg.configFile = {
    "quickshell/caelestia" = {
      source = caelestiaShellSrc;
      recursive = true;
    };

    # Symlink for compatibility, do NOT install individual files under .config/caelestia if you use this!
    "caelestia" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/quickshell/caelestia";
    };

    # Custom completions (if needed, points to your local override)
    "fish/completions/caelestia.fish" = {
      source = ./caelestia-completions.fish;
    };
  };

  # Data files (example, adjust if you want data from the GitHub repo)
  xdg.dataFile = {
    "caelestia/scripts" = {
      source = "${caelestiaShellSrc}/utils";
      recursive = true;
    };
  };

  # Dynamic home paths—no hardcoding!
  home.sessionVariables = {
    C_DATA = "${config.home.homeDirectory}/.local/share/caelestia";
    C_STATE = "${config.home.homeDirectory}/.local/state/caelestia";
    C_CACHE = "${config.home.homeDirectory}/.cache/caelestia";
    C_CONFIG = "${config.home.homeDirectory}/.config/caelestia";
  };

  # Directory setup and permissions (no hardcoded user/home)
  home.activation.caelestiaSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${config.home.homeDirectory}/.local/share/caelestia
    mkdir -p ${config.home.homeDirectory}/.local/state/caelestia/scheme
    mkdir -p ${config.home.homeDirectory}/.cache/caelestia/thumbnails
    mkdir -p ${config.home.homeDirectory}/.config/caelestia

    if [ -d ${config.home.homeDirectory}/.local/state/caelestia/scheme ]; then
      find ${config.home.homeDirectory}/.local/state/caelestia/scheme -name "*.txt" -exec chmod u+w {} \; 2>/dev/null || true
    fi
  '';
}
