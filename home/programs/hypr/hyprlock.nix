# Hyprlock configuration
# Adapted from https://github.com/karol-broda/nixos-config
# Uses Catppuccin Frappé colors and phosphor icons bundled with the quickshell config
{pkgs, ...}: {
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;

    settings = {
      # ─── Catppuccin Frappé color variables ───────────────────────────────────
      "$base" = "rgb(303446)";
      "$surface0" = "rgb(414559)";
      "$surface1" = "rgb(51576d)";
      "$text" = "rgb(c6d0f5)";
      "$textAlpha" = "c6d0f5";
      "$lavender" = "rgb(babbf1)";
      "$lavenderAlpha" = "babbf1";
      "$mauve" = "rgb(ca9ee6)";
      "$mauveAlpha" = "ca9ee6";
      "$red" = "rgb(e78284)";
      "$yellow" = "rgb(e5c890)";
      "$subtext0" = "rgb(a5adce)";

      # ─── Fonts ───────────────────────────────────────────────────────────────
      # EB Garamond is declared in nixos/nixos/hyprland.nix fonts.packages
      "$font" = "EB Garamond";

      # Phosphor icons bundled inside the quickshell config directory
      "$iconsPath" = "~/.config/quickshell/default/assets/phosphor-icons/bold";

      # ─── General ─────────────────────────────────────────────────────────────
      general = {
        hide_cursor = true;
      };

      # ─── Background ──────────────────────────────────────────────────────────
      # CHANGEME: point to your actual wallpaper file
      background = [
        {
          monitor = "";
          path = "~/Pictures/wallpaper.jpg";
          blur_passes = 2;
          blur_size = 6;
          color = "$base";
        }
      ];

      # ─── Status icons (top-left) ─────────────────────────────────────────────
      image = [
        {
          monitor = "";
          path = "$iconsPath/keyboard-bold.svg";
          size = 18;
          border_size = 0;
          rounding = 0;
          position = "30, -28";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "";
          path = "$iconsPath/battery-full-bold.svg";
          size = 18;
          border_size = 0;
          rounding = 0;
          position = "30, -56";
          halign = "left";
          valign = "top";
        }
      ];

      # ─── Labels ──────────────────────────────────────────────────────────────
      label = [
        # Keyboard layout (top-left, next to icon)
        {
          monitor = "";
          text = "$LAYOUT";
          color = "$text";
          font_size = 14;
          font_family = "$font";
          position = "56, -30";
          halign = "left";
          valign = "top";
        }
        # Battery percentage (top-left, next to icon)
        {
          monitor = "";
          text = "cmd[update:30000] cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 | xargs -I{} echo '{}%'";
          color = "$text";
          font_size = 14;
          font_family = "$font";
          position = "56, -58";
          halign = "left";
          valign = "top";
        }
        # Large clock (top-right)
        {
          monitor = "";
          text = "$TIME";
          color = "$text";
          font_size = 90;
          font_family = "$font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        # Date (top-right, below clock)
        {
          monitor = "";
          text = "cmd[update:43200000] date +\"%A, %d %B %Y\"";
          color = "$subtext0";
          font_size = 22;
          font_family = "$font";
          position = "-30, -120";
          halign = "right";
          valign = "top";
        }
      ];

      # ─── Password input field ─────────────────────────────────────────────────
      "input-field" = [
        {
          monitor = "";
          size = "300, 60";
          outline_thickness = 3;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "$lavender";
          inner_color = "$surface0";
          font_color = "$text";
          font_family = "$font";
          fade_on_empty = false;
          placeholder_text = "<span foreground=\"##$textAlpha\"><i>logged in as </i><span foreground=\"##$lavenderAlpha\">$USER</span></span>";
          hide_input = false;
          check_color = "$lavender";
          fail_color = "$red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = "$yellow";
          rounding = 12;
          position = "0, 100";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
