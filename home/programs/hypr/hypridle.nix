# Hypridle configuration
# Auto-sleep after 3 minutes of inactivity.
#
# Two conditions must be true for anything to happen:
#   1. Session is Hyprland   — checked via ExecCondition at service start
#   2. On battery power      — checked dynamically inside each on-timeout
#      so plug/unplug mid-idle is handled correctly.
#
# Timeline (all timeouts are in seconds):
#   2m 30s — dim screen to 20% (battery only)
#   3m 00s — lock screen       (battery only)
#   3m 10s — DPMS displays off (battery only)
#   3m 30s — suspend           (battery only)
{pkgs, ...}: let
  # Helper: exits 0 only when the system is on battery power.
  # /sys/class/power_supply/AC*/online contains "1" when AC is connected.
  # If the file doesn't exist (no AC adapter node) we assume battery.
  onBattery = "${pkgs.bash}/bin/bash -c 'status=$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -1); [[ \"$status\" != \"1\" ]]'";
in {
  services.hypridle = {
    enable = true;
    package = pkgs.hypridle;

    settings = {
      general = {
        # Re-enable displays when coming back from sleep
        after_sleep_cmd = "hyprctl dispatch dpms on";

        # Lock via quickshell global shortcut (same as Super+L keybind)
        lock_cmd = "hyprctl dispatch global quickshell:lock";

        # Respect apps that inhibit idle (e.g. video players, presentations)
        ignore_dbus_inhibit = false;
      };

      listener = [
        # 2m 30s — dim screen as a heads-up (only on battery)
        {
          timeout = 150;
          on-timeout = "${onBattery} && brightnessctl -s set 20%";
          on-resume = "brightnessctl -r";
        }

        # 3m 00s — lock screen (only on battery)
        {
          timeout = 180;
          on-timeout = "${onBattery} && hyprctl dispatch global quickshell:lock";
        }

        # 3m 10s — turn off displays via DPMS (only on battery)
        {
          timeout = 190;
          on-timeout = "${onBattery} && hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }

        # 3m 30s — suspend system (only on battery)
        {
          timeout = 210;
          on-timeout = "${onBattery} && systemctl suspend";
        }
      ];
    };
  };

  # Restrict the hypridle systemd service to Hyprland sessions only.
  # ExecCondition exits non-zero → systemd skips starting the service
  # entirely when running under any other DE (GNOME, COSMIC, KDE, etc.).
  systemd.user.services.hypridle = {
    Service.ExecCondition = [
      "${pkgs.bash}/bin/bash -c 'test \"$XDG_CURRENT_DESKTOP\" = Hyprland'"
    ];
  };
}
