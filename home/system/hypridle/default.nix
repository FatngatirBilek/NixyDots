{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof noctalia-shell ipc call lockScreen lock || noctalia-shell ipc call lockScreen lock";
        before_sleep_cmd = "loginctl lock-session";
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "pidof noctalia-shell ipc call lockScreen lock || noctalia-shell ipc call lockScreen lock";
        }
        {
          timeout = 660;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
