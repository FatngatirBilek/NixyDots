{pkgs, ...}: {
  home.packages = [
    pkgs.libnotify
    pkgs.acpi
    (pkgs.writeShellScriptBin "lowbattery-alert.sh" ''
      SLEEP_TIME=5  # Time between checks
      SAFE_PERCENT=30  # Chill hain
      DANGER_PERCENT=15  # Warn
      CRITICAL_PERCENT=5  # Hibernate

      while [ true ]; do
        if [[ -n $(acpi -b | grep -i discharging) ]]; then
          rem_bat=$(acpi -b | grep -Eo "[0-9]+%" | grep -Eo "[0-9]+")

          if [[ $rem_bat -gt $SAFE_PERCENT ]]; then
            SLEEP_TIME=10
          else
            SLEEP_TIME=5
            if [[ $rem_bat -le $DANGER_PERCENT ]]; then
              SLEEP_TIME=2
              notify-send -u normal -a "Battery" "Battery Low" "Battery level is $rem_bat%."
            fi
            if [[ $rem_bat -le $CRITICAL_PERCENT ]]; then
              SLEEP_TIME=1
              notify-send -u critical -a "Battery" "Battery Critical" "Battery level is $rem_bat%! Plug in your charger."
            fi
          fi
        else
          SLEEP_TIME=10
        fi

        sleep $SLEEP_TIME
      done
    '')
  ];

  systemd.user.services.lowbattery-alert = {
    Unit = {
      Description = "Low Battery Notification Service";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScriptBin "lowbattery-alert.sh" ''
        SLEEP_TIME=5
        SAFE_PERCENT=30
        DANGER_PERCENT=15
        CRITICAL_PERCENT=5

        while [ true ]; do
          if [[ -n $(acpi -b | grep -i discharging) ]]; then
            rem_bat=$(acpi -b | grep -Eo \"[0-9]+%\" | grep -Eo \"[0-9]+\")

            if [[ $rem_bat -gt $SAFE_PERCENT ]]; then
              SLEEP_TIME=10
            else
              SLEEP_TIME=5
              if [[ $rem_bat -le $DANGER_PERCENT ]]; then
                SLEEP_TIME=2
                notify-send -u normal -a \"Battery\" \"Battery Low\" \"Battery level is $rem_bat%.\"
              fi
              if [[ $rem_bat -le $CRITICAL_PERCENT ]]; then
                SLEEP_TIME=1
                notify-send -u critical -a \"Battery\" \"Battery Critical\" \"Battery level is $rem_bat%! Plug in your charger.\"
              fi
            fi
          else
            SLEEP_TIME=10
          fi

          sleep $SLEEP_TIME
        done
      ''}/bin/lowbattery-alert.sh";
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
