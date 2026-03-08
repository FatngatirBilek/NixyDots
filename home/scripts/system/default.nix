# - ## System
#-
#- Usefull quick scripts
#-
#- - `menu` - Open wofi with drun mode. (wofi)
#- - `powermenu` - Open power dropdown menu. (wofi)
#- - `gpu-mode` - Toggle between RTD3 (Intel only, no HDMI) and HDMI (Intel + NVIDIA) mode.
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
  # Toggle GPU mode between:
  #   rtd3 → AQ_DRM_DEVICES=card1 only (Intel), NVIDIA enters D3cold, no HDMI
  #   hdmi → AQ_DRM_DEVICES=card1:card0 (Intel + NVIDIA), HDMI works, no RTD3
  #
  # Writes an override file at ~/.config/environment.d/z-gpu-override.conf
  # which is read AFTER 10-home-manager.conf (z > 1), so it wins.
  # systemd environment.d uses LAST value seen — z-gpu-override.conf is
  # guaranteed to be read last alphabetically.
  # Then restarts the Hyprland UWSM session to apply the new env.
  gpu-mode = pkgs.writeShellScriptBin "gpu-mode" ''
    OVERRIDE_FILE="$HOME/.config/environment.d/z-gpu-override.conf"
    CURRENT=""

    # Read current mode from override file if it exists
    if [ -f "$OVERRIDE_FILE" ]; then
      CURRENT=$(grep "^AQ_DRM_DEVICES=" "$OVERRIDE_FILE" | cut -d= -f2)
    else
      CURRENT=$(systemctl --user show-environment | grep "^AQ_DRM_DEVICES=" | cut -d= -f2)
    fi

    if [ "$CURRENT" = "/dev/dri/card1" ]; then
      # Switch to HDMI mode (Intel primary + NVIDIA secondary)
      # Both EGL and Vulkan ICDs enabled so aquamarine can init a renderer
      # on card0 (NVIDIA) and blit frames to the HDMI output
      NEW_MODE="hdmi"
      printf '%s\n' \
        "AQ_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0" \
        "__EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json:/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json" \
        "VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json" \
        > "$OVERRIDE_FILE"
    else
      # Switch to RTD3 mode (Intel only)
      # Mesa-only EGL + Intel-only Vulkan → GLVND never loads libEGL_nvidia.so
      # → no /dev/nvidiactl reference → NVIDIA enters D3cold
      NEW_MODE="rtd3"
      printf '%s\n' \
        "AQ_DRM_DEVICES=/dev/dri/card1" \
        "__EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json" \
        "VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json" \
        > "$OVERRIDE_FILE"
    fi

    echo "Switched to $NEW_MODE mode"
    cat "$OVERRIDE_FILE"
    echo "Restarting Hyprland session in 3 seconds..."
    sleep 3

    # Gracefully restart Hyprland via UWSM — logs out and back in with new env
    uwsm stop
  '';
in {home.packages = [menu powermenu quickmenu gpu-mode];}
