# Hyprpaper configuration
# CHANGEME: update the wallpaper path to your actual wallpaper file.
# You can also set it at runtime with:
#   hyprctl hyprpaper wallpaper ",/path/to/wallpaper.jpg"
{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [pkgs.hyprpaper];

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    ipc = true
    splash = false

    preload = ${inputs.thirr-wallpapers}/wallpapers/wallpaper.jpg

    wallpaper = ,${inputs.thirr-wallpapers}/wallpapers/wallpaper.jpg
  '';
}
