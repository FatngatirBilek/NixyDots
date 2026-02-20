{pkgs, ...}: let
  lowBatteryScript = pkgs.writeShellApplication {
    name = "lowbattery-alert";
    runtimeInputs = [pkgs.acpi pkgs.coreutils pkgs.libnotify];
    text = ''
      SLEEP_TIME=5  # Time between checks
      SAFE_PERCENT=30  # Chill hain
      DANGER_PERCENT=15  # Warn
      CRITICAL_PERCENT=5  # Hibernate

      last_state="charged"

      while true; do
        if acpi -b | grep -qi discharging; then
          rem_bat=$(acpi -b | grep -Eo "[0-9]+%" | grep -Eo "[0-9]+")
          if [[ $rem_bat -le $CRITICAL_PERCENT ]]; then
            if [[ "$last_state" != "critical" ]]; then
              notify-send -u critical -a "Battery" "Battery Critical" "Battery level is $rem_bat%! Plug in your charger."
              last_state="critical"
            fi
            SLEEP_TIME=1
          elif [[ $rem_bat -le $DANGER_PERCENT ]]; then
            if [[ "$last_state" != "danger" ]]; then
              notify-send -u normal -a "Battery" "Battery Low" "Battery level is $rem_bat%."
              last_state="danger"
            fi
            SLEEP_TIME=2
          elif [[ $rem_bat -le $SAFE_PERCENT ]]; then
            if [[ "$last_state" != "normal" ]]; then
              notify-send -u low -a "Battery" "Battery Notice" "Battery level is $rem_bat%."
              last_state="normal"
            fi
            SLEEP_TIME=5
          else
            last_state="discharging"
            SLEEP_TIME=10
          fi
        else
          last_state="charged"
          SLEEP_TIME=10
        fi
        sleep $SLEEP_TIME
      done
    '';
  };
in {
  home.packages = [
    lowBatteryScript
  ];

  systemd.user.services.lowbattery-alert = {
    Unit = {
      Description = "Low Battery Notification Service";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${lowBatteryScript}/bin/lowbattery-alert";
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
