{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      shell = {
        avatar_path = "${config.home.homeDirectory}/.face.png";
      };
      wallpaper = {
        enabled = true;
        directory = "${inputs.thirr-wallpapers}/wallpapers/";
        enableMultiMonitorDirectories = false;
        recursiveSearch = false;
        setWallpaperOnAllMonitors = true;
        defaultWallpaper = "${inputs.thirr-wallpapers}/wallpapers/wallpaper.jpg";
        fillMode = "crop";
        fillColor = "#000000";
        randomEnabled = false;
        randomIntervalSec = 300;
        transitionDuration = 1500;
        transitionType = "random";
        transitionEdgeSmoothness = 0.05;
        monitors = [];
      };
    };
  };
}
