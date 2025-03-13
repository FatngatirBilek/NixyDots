# Hyprlock is a lockscreen for Hyprland
{
  config,
  lib,
  inputs,
  ...
}: let
  foreground = "rgba(5, 5, 5, 0.70)";
  # imageStr = toString config.stylix.image; # if i want to use wallpaper as hyprlock bg
  font = config.stylix.fonts.serif.name;
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
        no_fade_in = false;
        disable_loading_bar = false;
      };

      # BACKGROUND
      background = lib.mkForce {
        monitor = "";
        path = inputs.thirr-wallpapers + "/wallpapers/nix.png";
        blur_passes = 0;
        contrast = 0.8916;
        brightness = 0.7172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };

      label = [
        {
          # Day-Month-Date
          monitor = "";
          text = ''cmd[update:1000] echo "<span>$(date +"%I:%M")</span>"'';
          shadow_passes = "1";
          shadow_boost = "0.5";
          color = foreground;
          font_size = "65";
          font_family = font + " Bold";
          position = "0, 300";
          halign = "center";
          valign = "center";
        }
        # USER
        {
          monitor = "";
          text = "    $USER";
          color = foreground;
          outline_thickness = 2;
          dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = true;
          font_size = 18;
          font_family = font + " Bold";
          position = "0, -180";
          halign = "center";
          valign = "center";
        }
      ];

      # INPUT FIELD
      input-field = lib.mkForce {
        monitor = "";
        size = "300, 60";
        outline_thickness = 2;
        dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true;
        outer_color = "rgba(255, 255, 255, 0)";
        inner_color = "rgba(255, 255, 255, 0.1)";
        font_color = foreground;
        fade_on_empty = false;
        font_family = font + " Bold";
        placeholder_text = "<i>🔒 Enter Password</i>";
        hide_input = false;
        position = "0, -250";
        halign = "center";
        valign = "center";
      };
    };
  };
}
