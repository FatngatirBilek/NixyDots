# - ## Brightness
#-
#- This module provides a set of scripts to control the brightness of the screen.
#- Supports both laptop display (brightnessctl) and external HDMI monitors (ddcutil/DDC-CI).
#-
#- - `brightness-up` increases brightness of all displays by 5%.
#- - `brightness-down` decreases brightness of all displays by 5%.
#- - `brightness-set [value]` sets brightness of all displays to the given value.
#- - `brightness-change [up|down] [value]` changes brightness by the given value.
{pkgs, ...}: let
  increments = "5";

  # Helper script to set brightness on all displays
  brightness-all = pkgs.writeShellScriptBin "brightness-all" ''
    action="$1"  # "up", "down", or a numeric value
    increment="''${2:-${increments}}"

    # Control laptop display via brightnessctl
    if command -v brightnessctl &> /dev/null; then
      case "$action" in
        up)
          brightnessctl -e4 -n2 set "''${increment}%+" 2>/dev/null || true
          ;;
        down)
          brightnessctl -e4 -n2 set "''${increment}%-" 2>/dev/null || true
          ;;
        *)
          # Assume it's a numeric value
          if echo "$action" | grep -qE '^[0-9]+$'; then
            brightnessctl -e4 set "''${action}%" 2>/dev/null || true
          fi
          ;;
      esac
    fi

    # Control external HDMI monitors via ddcutil (DDC-CI)
    if command -v ddcutil &> /dev/null; then
      # Get list of detected displays (extract display numbers)
      displays=$(ddcutil detect --brief 2>/dev/null | grep "^Display" | awk '{print $2}' || echo "")

      if [ -n "$displays" ]; then
        for display in $displays; do
          # Get current brightness using sed to parse ddcutil output
          # Add retry logic since some monitors need time to respond
          current=""
          for attempt in 1 2 3; do
            current=$(ddcutil getvcp --display="$display" 10 2>/dev/null | sed -n 's/.*current value = *\([0-9]*\).*/\1/p' || echo "")
            [ -n "$current" ] && break
            sleep 0.2
          done

          if [ -n "$current" ] && echo "$current" | grep -qE '^[0-9]+$'; then
            case "$action" in
              up)
                new_brightness=$((current + increment))
                if [ $new_brightness -gt 100 ]; then new_brightness=100; fi
                ddcutil setvcp --display="$display" 10 "$new_brightness" 2>/dev/null || true
                sleep 0.3
                ;;
              down)
                new_brightness=$((current - increment))
                if [ $new_brightness -lt 0 ]; then new_brightness=0; fi
                ddcutil setvcp --display="$display" 10 "$new_brightness" 2>/dev/null || true
                sleep 0.3
                ;;
              *)
                if echo "$action" | grep -qE '^[0-9]+$'; then
                  if [ "$action" -ge 0 ] && [ "$action" -le 100 ]; then
                    ddcutil setvcp --display="$display" 10 "$action" 2>/dev/null || true
                    sleep 0.3
                  fi
                fi
                ;;
            esac
          fi
        done
      fi
    fi
  '';

  brightness-change = pkgs.writeShellScriptBin "brightness-change" ''
    case "$1" in
      up)
        brightness-all up "''${2:-${increments}}"
        ;;
      down)
        brightness-all down "''${2:-${increments}}"
        ;;
    esac
  '';

  brightness-set = pkgs.writeShellScriptBin "brightness-set" ''
    brightness-all "''${1:-100}"
  '';

  brightness-up = pkgs.writeShellScriptBin "brightness-up" ''
    brightness-change up ${increments}
  '';

  brightness-down = pkgs.writeShellScriptBin "brightness-down" ''
    brightness-change down ${increments}
  '';
in {
  home.packages = [
    pkgs.brightnessctl
    pkgs.ddcutil
    brightness-all
    brightness-change
    brightness-up
    brightness-down
    brightness-set
  ];
}
