{
  config,
  pkgs,
  lib,
  ...
}: let
  # Collect all system font files into one derivation as real files (no symlinks).
  # OnlyOffice runs inside an FHS env and cannot reliably follow symlinks into
  # /nix/store, so we need actual files in a user-writable location.
  allSystemFonts = pkgs.runCommand "onlyoffice-system-fonts" {} (
    "mkdir -p $out\n"
    + lib.concatMapStrings
    (pkg: ''
      if [ -d "${pkg}/share/fonts" ]; then
        find "${pkg}/share/fonts" -type f \( -iname "*.ttf" -o -iname "*.otf" \) | \
          while IFS= read -r font; do
            cp --no-clobber "$font" "$out/" 2>/dev/null || true
          done
      fi
    '')
    config.fonts.packages
  );
in {
  environment.systemPackages = [pkgs.onlyoffice-desktopeditors];

  # On every activation (nixos-rebuild switch / user login):
  #   1. Repopulate ~/.local/share/fonts/nix-system/ with real font files so
  #      OnlyOffice (and anything else) can find them without chasing symlinks.
  #   2. Wipe OnlyOffice's own font cache so it rescans on next launch.
  system.userActivationScripts.onlyoffice-fonts = {
    text = ''
      NIX_FONTS_DIR="$HOME/.local/share/fonts/nix-system"

      # Repopulate — clear stale files from previous generation, then copy fresh.
      rm -rf "$NIX_FONTS_DIR"
      mkdir -p "$NIX_FONTS_DIR"
      cp ${allSystemFonts}/* "$NIX_FONTS_DIR/" 2>/dev/null || true

      # Refresh fontconfig user cache so the new files are indexed immediately.
      ${pkgs.fontconfig}/bin/fc-cache -f "$NIX_FONTS_DIR" 2>/dev/null || true

      # Clear OnlyOffice's own font cache to force a full rescan on next launch.
      OO_CACHE="$HOME/.local/share/onlyoffice/desktopeditors/data/fonts"
      if [ -d "$OO_CACHE" ]; then
        rm -rf "$OO_CACHE"
      fi
    '';
  };
}
