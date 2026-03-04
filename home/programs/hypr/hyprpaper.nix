# Hyprpaper wallpaper daemon
# Uses the home-manager services.hyprpaper module which handles the systemd
# user service, package, and config file generation automatically.
# Remove exec-once = hyprpaper from hyprland.nix — the service starts it.
{inputs, ...}: {
  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = true;
      splash = false;

      preload = [
        "${inputs.thirr-wallpapers}/wallpapers/wallpaper.jpg"
      ];

      wallpaper = [
        {
          monitor = "eDP-1";
          path = "${inputs.thirr-wallpapers}/wallpapers/wallpaper.jpg";
        }
        {
          monitor = "";
          path = "${inputs.thirr-wallpapers}/wallpapers/wallpaper.jpg";
        }
      ];
    };
  };
}
