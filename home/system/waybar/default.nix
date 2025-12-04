{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.waybar;
in {
  options.waybar = {
    enable = mkEnableOption "Enable waybar panel";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
      };
      style = ''
        @define-color accent #2362ba;
        * {
          font-family: "Noto Sans", "JetBrainsMono NF";
          font-size: 13px;
          font-weight: 600;
          color: #DDDDDD;
          min-height: 0px;
          min-width: 0px;
        }
        #custom-battery {
          padding-left: 10px;
          padding-right: 10px;
          margin-left: 8px;
          margin-right: 8px;
        }
        tooltip {
          background-color: rgba(0,0,0,0.1);
          text-shadow: none;
        }
        #custom-notification {
          font-size: 16px
        }
        #waybar {
          background: none;
        }
        .modules-left {
          background: rgba(0,0,0,0.2);
          border-radius: 0 0 15px 0;
          padding: 0 10px 0 0;
        }
        .modules-center {
          background: rgba(0,0,0,0.2);
          border-radius: 0 0 15px 15px;
          padding: 0 20px;
        }
        .modules-right {
          background: rgba(0,0,0,0.2);
          border-radius: 0 0 0 15px;
          padding: 0 0 0 10px;
        }
        #custom-cog {
          font-size: 16px;
        }
        #custom-nixos {
          font-size: 20px;
          border-radius: 0px;
          padding: 1px 0px 0px 0px;
          margin-left: 8px;
        }
        #scroll,
        #cava,
        #clock,
        #hardware,
        #scripts,
        #window,
        #cpu,
        #custom-gpu,
        #network,
        #pulseaudio,
        #pulseaudio-mic,
        #custom-lock,
        #custom-reboot,
        #custom-logout,
        #custom-shutdown,
        #custom-notification,
        #custom-weather,
        #batteries,
        #tray {
          border-radius: 8px;
        }
        #window {
            font-size: 14px;
            opacity: 100;
            transition: opacity 1s ease-in-out
        }
        window#waybar.empty #window {
            opacity: 0;
        }
        window#waybar.empty .modules-center {
            background: none;
        }
        @keyframes gradient {
        	0% {
        		background-position: 100% 0%;
        	}
        	100% {
        		background-position: 15% 100%;
        	}
        }
        #cava {
          padding: 5px 10px 0px 10px;
          color: #4575DA;
        }
        #custom-notification {
          padding: 0px 10px 0px 8px;
        }
        #tray {
          padding: 0px 8px 0px 8px;
        }
        #custom-shutdown {
          padding: 0 13px 0 8px;
          margin-left: 4px;
          font-size: 18px;
        }
        #custom-notification,
        #cpu,
        #network,
        #custom-gpu,
        #pulseaudio,
        #pulseaudio-mic,
        #custom-logout,
        #custom-reboot,
        #custom-shutdown,
        #custom-lock {
          margin-top: 2px;
          margin-bottom: 2px;
          transition: background-color 200ms;
        }
        #custom-notification {
          margin-left: 6px;
        }
        #custom-notification:hover,
        #cpu:hover,
        #network:hover,
        #custom-gpu:hover,
        #pulseaudio:hover,
        #pulseaudio-mic:hover,
        #custom-logout:hover,
        #custom-reboot:hover,
        #custom-shutdown:hover,
        #custom-lock:hover {
          transition: background-color 200ms;
          background-color: rgba(255,255,255,0.2);
        }
        #custom-lock {
          font-size: 18px;
          padding: 0 13px 0 8px;
        }
        #custom-logout {
          font-size: 18px;
          padding: 0 10px 0 10px;
        }
        #custom-reboot {
          padding: 0 12px 0 8px;
          font-size: 18px;
        }
        @keyframes workspacesanim {
            0% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 20px, @accent 20px);
            }
            10% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 18px, @accent 18px);
            }
            20% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 16px, @accent 16px);
            }
            30% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 14px, @accent 14px);
            }
            40% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 12px, @accent 12px);
            }
            50% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 10px, @accent 10px);
            }
            60% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 8px, @accent 8px);
            }
            70% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 6px, @accent 6px);
            }
            80% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 4px, @accent 4px);
            }
            90% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 2px, @accent 2px);
            }
            100% {
                background: linear-gradient(to bottom, rgba(0,0,0,0) 0px, @accent 0px);
            }
        }
        #workspaces button label {
          font-size: 16px;
        }
        #workspaces button.urgent {
          background-color: #3275a8;
        }
        #workspaces button:nth-child(1) {
          border-radius: 10px 5px 5px 10px;
        }
        #workspaces button:nth-child(10) {
          border-radius: 5px 10px 10px 5px;
        }
        #workspaces button {
          padding: 0px 10px 0 4px;
          margin: 4px 0px;
          border-radius: 5;
        }
        #workspaces button:hover {
          background-color: rgba(255,255,255,0.25);
        }
        #workspaces button.active {
          animation-name: workspacesanim;
          animation-fill-mode: both;
          animation-duration: 300ms;
          animation-direction: normal;
        }
        #cpu,
        #clock,
        #network,
        #custom-vpn,
        #custom-cputemp,
        #custom-colorpicker,
        #submap,
        #idle_inhibitor,
        #custom-updates,
        #gamemode,
        #custom-camera,
        #custom-notifications,
        #custom-recorder,
        #custom-batterysaver,
        #bluetooth,
        #disk,
        #memory,
        #pulseaudio,
        #pulseaudio.mic,
        #backlight {
          padding: 0px 6px 0px 3px;
        }
        #custom-github {
          padding-right: 6px;
        }
        #gamemode,
        #submap,
        #custom-recorder,
        #custom-vpn,
        #custom-github,
        #custom-updates,
        #bluetooth.connected {
          background: shade(alpha(@foreground, 0.1), 0.8);
          border-radius: 8px;
        }
        #language {
          color: #7aa2f7;
          margin-top: 3px;
        }
        #idle_inhibitor,
        #pulseaudio,
        #pulseaudio.mic {
          color: #7aa2f7;
        }
        #backlight {
          color: #fab387;
        }
        #memory {
          color: shade(#cca0e4, 0.8);
        }
        #disk {
          color: shade(#7aa2f7, 0.8);
        }
        #custom-recorder {
          color: #d78787;
        }
        #cpu {
          color: shade(#a6e3a1, 0.8);
        }
        #custom-batterysaver.powersave,
        #custom-batterysaver.power {
          color: #a6e3a1;
        }
        #custom-batterysaver.default,
        #custom-batterysaver.normal {
          color: #7aa2f7;
        }
        #custom-batterysaver.performance {
          color: #d78787;
        }
        #network {
          color: #a6e3a1;
        }
        #network.disabled,
        #network.disconnected {
          color: #d78787;
        }
        @keyframes blink {
          to {
            background-color: alpha(red, 0.6);
            color: @foreground;
          }
        }
        @keyframes blink-blue {
          to {
            background-color: alpha(#7aa2f7, 0.6);
            color: @foreground;
          }
        }
        #battery.warning:not(.charging),
        #battery.critical:not(.charging) {
          animation-name: blink;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
        #bluetooth.discoverable,
        #bluetooth.discovering,
        #bluetooth.pairable {
          animation-name: blink-blue;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
        #batteries {
          margin-right: 0px;
          border-radius: 8px 0px 0px 8px;
        }
      '';
      settings = {
        main = {
          layer = "top";
          position = "top";
          modules-left = [
            "group/powermenu"
            "niri/workspaces"
            "group/stuff"
          ];
          modules-center = [
            "niri/window"
          ];
          modules-right = [
            "tray"
            "group/scroll"
            "group/hardware"
            "custom/battery"
          ];
          "cava" = {
            framerate = 60;
            format-icons = [
              "▁"
              "▂"
              "▃"
              "▄"
              "▅"
              "▆"
              "▆"
              "▇"
              "█"
            ];
            bar_delimiter = 0;
            bars = 30;
            input_delay = 0;
            sleep_timer = 300;
          };
          "hyprland/window" = {
            format = "{}";
            icon = true;
            icon-size = 18;
            rewrite = {
              "(.*)Mozilla Firefox" = "Mozilla Firefox";
              "(.*)Ablaze Floorp" = "Ablaze Floorp";
            };
          };
          "niri/window" = {
            format = "{}";
            icon = false;
            icon-size = 24;
            separate-outputs = false;
            rewrite = {
              "(.*) - Mozilla Firefox" = "🌎 $1";
              "(.*) - zsh" = "> [$1]";
            };
          };
          "niri/language" = {
            format = "Lang: {long}";
            format-en = "AMERICA, HELL YEAH!";
            format-tr = "As bayrakları";
          };
          "group/powermenu" = {
            drawer = {
              "children-class" = "power-menu";
              "transition-duration" = 500;
              "transition-left-to-right" = true;
            };
            orientation = "horizontal";
            modules = [
              "custom/nixos"
              "custom/shutdown"
              "custom/reboot"
              "custom/logout"
              "custom/lock"
            ];
          };
          "group/stuff" = {
            orientation = "horizontal";
            modules = [
              "clock"
              "hyprland/workspaces"
              "custom/notification"
            ];
          };
          "custom/shutdown" = {
            format = "<span color='#ff5e5e'></span>";
            on-click = "systemctl poweroff";
            tooltip = false;
          };
          "custom/reboot" = {
            format = "<span color='#79b4fc'>󰑓</span>";
            on-click = "systemctl reboot";
            tooltip = false;
          };
          "custom/logout" = {
            format = "<span color='#63c773'>󰍃</span>";
            on-click = "hyprctl dispatch exit";
            tooltip = false;
          };
          "custom/lock" = {
            format = "<span color='#787878'></span>";
            on-click = "hyprlock";
            tooltip = false;
          };
          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            all-outputs = true;
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
              "6" = [];
              "7" = [];
              "8" = [];
              "9" = [];
            };
            format-icons = {
              "empty" = "";
              "default" = "";
            };
          };
          "tray" = {
            spacing = 8;
            icon-size = 12;
          };
          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              # Named workspaces
              browser = "";
              discord = "";
              chat = "<b></b>";
              # Icons by state
              active = "";
              default = "";
            };
            all-outputs = true;
            disable-click = false;
            disable-markup = false;
            current-only = false;
            rewrite = {};
          };
          "group/scroll" = {
            orientation = "horizontal";
            modules = [
              "pulseaudio#mic"
              "pulseaudio"
              "backlight"
            ];
          };
          "group/hardware" = {
            drawer = {
              "children-class" = "fancy-stuff";
              "transition-duration" = 500;
              "transition-left-to-right" = false;
            };
            orientation = "horizontal";
            "modules" = [
              "custom/cog"
              "custom/vpn"
              "custom/weather"
              "network"
              "memory"
              "cpu"
              "temperature"
              "custom/gpu"
            ];
          };
          "pulseaudio#mic" = {
            format = "{format_source}";
            format-source = "{volume}%  ";
            format-source-muted = "";
            on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            on-scroll-down = "pactl set-source-volume @DEFAULT_SOURCE@ -5%";
            on-scroll-up = "pactl set-source-volume @DEFAULT_SOURCE@ +5%";
          };
          "pulseaudio" = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-muted = "󰝟 ";
            format-icons = {
              "headphones" = "  ";
              "handsfree" = "  ";
              "headset" = "  ";
              "phone" = "  ";
              "portable" = "  ";
              "car" = "  ";
              "default" = [
                "  "
                "  "
              ];
            };
            on-click = "pgrep -x myxer && killall -q myxer || myxer";
            on-click-middle = "pavucontrol";
            on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +4096";
            on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -4096";
            smooth-scrolling-threshold = 1;
          };
          "custom/vpn" = {
            format = "󰖂 ";
            exec = "echo '{\"class\": \"connected\"}'";
            exec-if = "test -d /proc/sys/net/ipv4/conf/tun0";
            return-type = "json";
            interval = 5;
          };
          "network" = {
            interval = 2;
            format-wifi = "   {bandwidthDownBits}";
            format-ethernet = " 󰈀  {bandwidthDownBits}";
            format-disconnected = "󰈂";
            format-linked = "";
            tooltip-format = "{ipaddr}";
            tooltip-format-wifi = "{essid} ({signalStrength}%)   \n{ipaddr} | {frequency} MHz{icon} \n {bandwidthDownBits}  {bandwidthUpBits} ";
            tooltip-format-ethernet = "{ifname} 󰈀 \n{ipaddr} | {frequency} MHz{icon} \n󰈀 {bandwidthDownBits}  {bandwidthUpBits} ";
            tooltip-format-disconnected = "No Connection";
          };
          "backlight" = {
            device = "acpi_video1";
            format = "{percent}% {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
            on-scroll-down = "brightnessctl s 5%-";
            on-scroll-up = "brightnessctl s +5%";
            tooltip = false;
            smooth-scrolling-threshold = 1;
          };
          "custom/battery" = {
            interval = 10;
            exec = ''
              BAT=$(upower -e | grep BAT)
              if [ -z "$BAT" ]; then
                echo '{"text":"  --","tooltip":"No battery detected."}'
                exit
              fi
              PERCENT=$(upower -i "$BAT" | awk '/percentage:/ {gsub("%",""); print $2}')
              STATE=$(upower -i "$BAT" | awk '/state:/ {print $2}')
              ICON=""
              if [ "$PERCENT" -ge 95 ]; then ICON=""
              elif [ "$PERCENT" -ge 75 ]; then ICON=""
              elif [ "$PERCENT" -ge 50 ]; then ICON=""
              elif [ "$PERCENT" -ge 25 ]; then ICON=""
              fi

              if [ "$STATE" = "charging" ]; then
                TIME=$(upower -i "$BAT" | awk -F': ' '/time to full/ {print $2}')
                if [ -z "$TIME" ]; then
                  TIME_SHOW="Calculating..."
                else
                  TIME_SHOW="$TIME"
                fi
                TOOLTIP="Charging\n$TIME_SHOW"
              elif [ "$STATE" = "discharging" ]; then
                TIME=$(upower -i "$BAT" | awk -F': ' '/time to empty/ {print $2}')
                if [ -z "$TIME" ]; then
                  TIME_SHOW="Calculating..."
                else
                  TIME_SHOW="$TIME"
                fi
                TOOLTIP="$TIME_SHOW"
              else
                TOOLTIP="Not Charging"
              fi

              # Add an extra space after the icon to avoid overlap
              echo "{\"text\":\"$ICON  $PERCENT%\",\"tooltip\":\"$TOOLTIP\"}"
            '';
            return-type = "json";
            format = "{}";
            tooltip = true;
          };
          "memory" = {
            format = "{}% ";
            interval = 1;
          };
          "disk" = {
            interval = 600;
            format = "{percentage_used}% ";
            path = "/";
          };
          "cpu" = {
            interval = 1;
            format = "{usage}%  ";
            on-click = "kitty btop";
          };
          "custom/gpu" = {
            interval = 3;
            exec = "gpu";
            return-type = "json";
            format = "{}";
            tooltip = true;
          };
          "custom/weather" = {
            format = "{}° ";
            tooltip = true;
            interval = 3600;
            exec = "wttrbar";
            return-type = "json";
          };
          "custom/cog" = {
            format = "  ";
            tooltip = false;
          };
          "custom/colorpicker" = {
            format = "{}";
            return-type = "json";
            interval = "once";
            exec = "$HOME/.config/waybar/bin/colpicker/colorpicker -j";
            on-click = "sleep 1 && $HOME/.config/waybar/bin/colpicker/colorpicker";
            signal = 1;
          };
          "idle_inhibitor" = {
            format = "{icon}";
            tooltip-format-activated = "Idle Inhibitor is active";
            tooltip-format-deactivated = "Idle Inhibitor is not active";
            format-icons = {
              "activated" = " ";
              "deactivated" = " ";
            };
          };
          "hyprland/submap" = {
            format = "{}";
            tooltip = false;
          };
          "custom/updates" = {
            format = "{}";
            interval = 3600;
            exec = "~/.config/waybar/bin/updatecheck";
            return-type = "json";
            exec-if = "exit 0";
            signal = 8;
          };
          "gamemode" = {
            hide-not-running = true;
            icon-spacing = 4;
            icon-size = 13;
            tooltip = true;
            tooltip-format = "Игр запущено: {count}";
          };
          "custom/camera" = {
            format = "{} ";
            interval = "once";
            exec = "[ -z \"$(lsmod | grep uvcvideo)\" ] && echo \"\nКамера отключена\" || echo \"\"";
            on-click = "~/.config/hypr/bin/camera-toggle";
            signal = 3;
          };
          "custom/nixos" = {
            exec = "nixos";
            return-type = "json";
            on-click = "anyrun";
            format = "{}";
            tooltip = true;
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
              "notification" = "󱅫";
              "none" = "󰂚";
              "dnd-notification" = "󰂛";
              "dnd-none" = "󰂛";
              "inhibited-notification" = "󱅫";
              "inhibited-none" = "󰂚";
              "dnd-inhibited-notification" = "󰂛";
              "dnd-inhibited-none" = "󰂛";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "sleep 0.1 && swaync-client -t -sw";
            on-click-right = "sleep 0.1 && swaync-client -d -sw";
            escape = false;
          };
          "clock" = {
            format = "{:%H:%M}";
            format-alt = "{:%A, %B %d, %Y (%R)}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              "mode" = "month";
              "mode-mon-col" = 3;
              "weeks-pos" = "right";
              "on-scroll" = 1;
              "on-click-right" = "mode";
              "format" = {
                "today" = "<span color='#a6e3a1'><b><u>{}</u></b></span>";
              };
            };
          };
          "custom/recorder" = {
            format = "{}";
            interval = "once";
            exec = "echo ''";
            tooltip = "false";
            exec-if = "pgrep 'wl-screenrec'";
            on-click = "exec $HOME/.config/waybar/bin/recorder";
            signal = 4;
          };
          "bluetooth" = {
            format-on = "";
            format-off = "";
            format-disabled = "";
            format-connected = "<b> {num_connections}</b>";
            format-connected-battery = " {device_alias} {device_battery_percentage}%";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            on-click = "rofi-bluetooth -config ~/.config/rofi/menu.d/network.rasi -i";
          };
        };
      };
    };
  };
}
