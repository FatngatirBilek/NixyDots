# - ## System
#-
#- Usefull quick scripts
#-
#- - `menu` - Open wofi with drun mode. (wofi)
#- - `powermenu` - Open power dropdown menu. (wofi)
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
          " Suspend"
          "󰑐 Reboot"
          "󰿅 Shutdown"
        )

        selected=$(printf '%s\n' "''${options[@]}" | wofi -p " Powermenu" --dmenu)
        selected=''${selected:2}

        case $selected in
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
          "󰖔 Night-shift"
          " Nixy"
        )

        selected=$(printf '%s\n' "''${options[@]}" | wofi -p " Quickmenu" --dmenu)

        selected=''${selected:2}

        case $selected in
          "Night-shift")
            night-shift
            ;;
          "Nixy")
            kitty nu -c nixy
            ;;
        esac
      fi
    '';
in {home.packages = [menu powermenu quickmenu];}
