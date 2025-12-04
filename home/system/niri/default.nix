{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  dms = cmd:
    [
      "dms"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in {
  home.packages = with pkgs; [
    swaybg
    pulseaudio
    myxer
  ];

  programs.niri = {
    enable = true;
    # package = pkgs.niri-unstable;
    settings = {
      input.keyboard.xkb.layout = "us";
      input.mouse.accel-speed = 1.0;
      input.touchpad = {
        tap = true;
        dwt = true;
        natural-scroll = true;
        click-method = "clickfinger";
      };
      input.tablet.map-to-output = "eDP-1";
      input.touch.map-to-output = "eDP-1";
      prefer-no-csd = true;

      layout = {
        gaps = 16;
        struts.left = 64;
        struts.right = 64;
        border.width = 4;
        always-center-single-column = true;
        empty-workspace-above-first = true;
        focus-ring = {
          width = 4;
          active.color = "#0654ba";
        };
        shadow.enable = false;
        tab-indicator = {
          position = "top";
          gaps-between-tabs = 10;
        };
      };
      window-rules = [
        {
          matches = [
            {is-window-cast-target = true;}
          ];
          focus-ring = {
            active = {color = "#f38ba8";};
            inactive = {color = "#7d0d2d";};
          };
          border = {
            inactive = {color = "#7d0d2d";};
          };
          shadow = {
            color = "#7d0d2d70";
          };
          tab-indicator = {
            active = {color = "#f38ba8";};
            inactive = {color = "#7d0d2d";};
          };
        }
        {
          geometry-corner-radius = {
            top-left = 12.0;
            top-right = 12.0;
            bottom-left = 12.0;
            bottom-right = 12.0;
          };
          clip-to-geometry = true;
          draw-border-with-background = false;
        }
      ];
      clipboard.disable-primary = true;
      overview.zoom = 0.5;
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

      switch-events = with config.lib.niri.actions; let
        sh = spawn "sh" "-c";
      in {
        tablet-mode-on.action = sh "notify-send tablet-mode-on";
        tablet-mode-off.action = sh "notify-send tablet-mode-off";
        lid-open.action = sh "notify-send lid-open";
        lid-close.action = sh "notify-send lid-close";
      };

      binds = with config.lib.niri.actions; let
        sh = spawn "sh" "-c";
        binds = {
          suffixes,
          prefixes,
          substitutions ? {},
        }: let
          replacer = lib.replaceStrings (lib.attrNames substitutions) (lib.attrValues substitutions);
          format = prefix: suffix: let
            actual-suffix =
              if lib.isList suffix.action
              then {
                action = lib.head suffix.action;
                args = lib.tail suffix.action;
              }
              else {
                inherit (suffix) action;
                args = [];
              };

            action = replacer "${prefix.action}-${actual-suffix.action}";
          in {
            name = "${prefix.key}+${suffix.key}";
            value.action.${action} = actual-suffix.args;
          };
          pairs = attrs: fn:
            lib.concatMap (
              key:
                fn {
                  inherit key;
                  action = attrs.${key};
                }
            ) (lib.attrNames attrs);
        in
          lib.listToAttrs (pairs prefixes (prefix: pairs suffixes (suffix: [(format prefix suffix)])));
      in
        lib.attrsets.mergeAttrsList [
          {
            "Mod+T".action = spawn "ghostty";
            # "Mod+D".action.spawn = dms "spotlight toggle";
            "Mod+D".action = spawn "wofi";
            "Mod+L".action.spawn = dms "lock lock";
            "Mod+P".action.spawn = dms "powermenu toggle";
            "Mod+V".action.spawn = dms "clipboard toggle";
            "Mod+O".action = show-hotkey-overlay;
            "Mod+Shift+S".action.screenshot = [];
            "Print".action.screenshot-screen = [];
            "Mod+Print".action.screenshot-window = [];
            "Mod+Insert".action = set-dynamic-cast-window;
            "Mod+Shift+Insert".action = set-dynamic-cast-monitor;
            "Mod+Delete".action = clear-dynamic-cast-target;
            "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
            "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            # "XF86AudioRaiseVolume".action.spawn = dms "audio increment 3";
            # "XF86AudioLowerVolume".action.spawn = dms "audio decrement 3";
            # "XF86AudioMute".action.spawn = dms "audio mute";
            # "XF86AudioMicMute".action.spawn = dms "audio micmute";
            "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
            "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";
            "Mod+Q".action = close-window;
            "Mod+Space".action = toggle-column-tabbed-display;
            "XF86AudioNext".action = focus-column-right;
            "XF86AudioPrev".action = focus-column-left;
            "Mod+Tab".action = focus-window-down-or-column-right;
            "Mod+Shift+Tab".action = focus-window-up-or-column-left;
          }
          (binds {
            suffixes."Left" = "column-left";
            suffixes."Down" = "window-down";
            suffixes."Up" = "window-up";
            suffixes."Right" = "column-right";
            prefixes."Mod" = "focus";
            prefixes."Mod+Ctrl" = "move";
            prefixes."Mod+Shift" = "focus-monitor";
            prefixes."Mod+Shift+Ctrl" = "move-window-to-monitor";
            substitutions."monitor-column" = "monitor";
            substitutions."monitor-window" = "monitor";
          })
          {
            "Mod+Space".action = switch-focus-between-floating-and-tiling;
            "Mod+Shift+Space".action = toggle-window-floating;
          }
          (binds {
            suffixes."Home" = "first";
            suffixes."End" = "last";
            prefixes."Mod" = "focus-column";
            prefixes."Mod+Ctrl" = "move-column-to";
          })
          (binds {
            suffixes."U" = "workspace-down";
            suffixes."I" = "workspace-up";
            prefixes."Mod" = "focus";
            prefixes."Mod+Ctrl" = "move-window-to";
            prefixes."Mod+Shift" = "move";
          })
          (binds {
            suffixes = lib.listToAttrs (
              map (n: {
                name = toString n;
                value = [
                  "workspace"
                  (n + 1)
                ];
              }) (lib.range 1 9)
            );
            prefixes."Mod" = "focus";
            prefixes."Mod+Shift" = "move-window-to";
          })
          {
            "Mod+Comma".action = consume-window-into-column;
            "Mod+Period".action = expel-window-from-column;
            "Mod+R".action = switch-preset-column-width;
            "Mod+F".action = maximize-column;
            "Mod+Shift+F".action = fullscreen-window;
            "Mod+C".action = center-column;
            "Mod+Minus".action = set-column-width "-10%";
            "Mod+Plus".action = set-column-width "+10%";
            "Mod+Shift+Minus".action = set-window-height "-10%";
            "Mod+Shift+Plus".action = set-window-height "+10%";
            "Mod+Shift+Escape".action = toggle-keyboard-shortcuts-inhibit;
            "Mod+Shift+E".action = quit;
            "Mod+Shift+P".action = power-off-monitors;
            "Mod+Shift+Ctrl+T".action = toggle-debug-tint;
          }
        ];
      outputs = {
        "eDP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 165.0;
          };
          position = {
            x = 0;
            y = 0;
          };
          enable = true;
          name = "eDP-1";
        };
        "HDMI-A-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 120.0;
          };
          position = {
            x = 1920;
            y = 0;
          };
          enable = true;
          name = "HDMI-A-1";
        };
      };
      spawn-at-startup = [
        {
          argv = [
            "swaybg"
            "--image"
            "${inputs.thirr-wallpapers}/wallpapers/wallpaper.jpg"
          ];
        }
        {
          command = [
            # "dms"
            # "run"
            # "-d"
          ];
        }
      ];
    };
  };
}
