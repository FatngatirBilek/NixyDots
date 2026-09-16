{pkgs, ...}: {
  services.hypridle = {
    enable = true;
    package = pkgs.hypridle;

    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "noctalia msg session lock";
      };
      listener = [
        {
          on-timeout = "noctalia msg session lock";
          timeout = 900;
        }
        {
          on-resume = "hyprctl dispatch dpms on";
          on-timeout = "hyprctl dispatch dpms off";
          timeout = 1200;
        }
      ];
    };
  };
}
