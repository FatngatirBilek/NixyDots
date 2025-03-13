# - ## System
#-
#- Usefull quick scripts
#-
#- - `menu` - Open wofi with drun mode. (wofi)
#- - `powermenu` - Open power dropdown menu. (wofi)
#- - `lock` - Lock the screen. (hyprlock)
{pkgs, ...}: let
  menu =
    pkgs.writeShellScriptBin "menu"
    # bash
    ''
      if pgrep wofi; then
      	pkill wofi
      else
      	wofi -p " Apps" --show drun
      fi
    '';

  powermenu =
    pkgs.writeShellScriptBin "powermenu"
    # bash
    ''
      if pgrep wofi; then
      	pkill wofi
      else
        options=(
          "󰌾 Lock"
          "󰍃 Logout"
          " Suspend"
          "󰑐 Reboot"
          "󰿅 Shutdown"
        )

        selected=$(printf '%s\n' "''${options[@]}" | wofi -p " Powermenu" --dmenu)
        selected=''${selected:2}

        case $selected in
          "Lock")
            ${pkgs.hyprlock}/bin/hyprlock
            ;;
          "Logout")
            hyprctl dispatch exit
            ;;
          "Suspend")
            systemctl suspend
            ;;
          "Reboot")
            systemctl reboot
            ;;
          "Shutdown")
            systemctl poweroff
            ;;
        esac
      fi
    '';

  quickmenu =
    pkgs.writeShellScriptBin "quickmenu"
    # bash
    ''
      if pgrep wofi; then
      	pkill wofi
      else
        options=(
          "󰅶 Caffeine"
          "󰖔 Night-shift"
          " Nixy"
          "󰈊 Hyprpicker"
        )

        selected=$(printf '%s\n' "''${options[@]}" | wofi -p " Quickmenu" --dmenu)

        selected=''${selected:2}

        case $selected in
          "Caffeine")
            caffeine
            ;;
          "Night-shift")
            night-shift
            ;;
          "Nixy")
            kitty nu -c nixy
            ;;
          "Hyprpicker")
            sleep 0.2 && ${pkgs.hyprpicker}/bin/hyprpicker -a
            ;;
        esac
      fi
    '';

  lock =
    pkgs.writeShellScriptBin "lock"
    # bash
    ''
      ${pkgs.hyprlock}/bin/hyprlock
    '';
in {home.packages = [menu powermenu lock quickmenu];}
