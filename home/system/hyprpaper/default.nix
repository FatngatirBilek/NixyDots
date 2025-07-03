# Hyprpaper is used to set the wallpaper on the system
{
  # The wallpaper is set by stylix
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [
        "~/Downloads/urban.png"
      ];
      wallpaper = [
        "eDP-1,~/Downloads/urban.png"
      ];
    };
  };
}
