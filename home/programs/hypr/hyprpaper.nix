# Hyprpaper wallpaper daemon
# Uses the home-manager services.hyprpaper module which handles the systemd
# user service, package, and config file generation automatically.
# Remove exec-once = hyprpaper from hyprland.nix — the service starts it.
{inputs, ...}: {
  # Prevent hyprpaper's systemd user service from loading libEGL_nvidia.so.
  # hyprpaper runs as a separate systemd unit so it does NOT inherit the
  # __EGL_VENDOR_LIBRARY_FILENAMES restriction set in hyprland.nix env block —
  # without this, GLVND enumerates all EGL ICDs including NVIDIA's, which opens
  # /dev/nvidiactl and holds a runtime PM reference that blocks RTD3.
  #
  # home-manager's services.hyprpaper generates its own [Service] section, so we
  # must merge into it via systemd.user.services.hyprpaper.Service (the raw INI
  # section attrset). Keys with leading underscores are valid in systemd env
  # strings — they just can't be Nix attrset keys, so we use a list of strings.
  systemd.user.services.hyprpaper.Service = {
    Environment = [
      "__EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json"
    ];
  };

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
