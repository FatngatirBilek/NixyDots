{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.hyprland;
in {
  imports = [
    ./polkitagent.nix
    ./bindings.nix
    ./animations.nix
    ./env.nix
  ];

  options.hyprland = {
    enable = mkEnableOption "Enable my Hyprland configuration";
    from-unstable = mkEnableOption "Use Hyprland package from UNSTABLE nixpkgs";
    stable = mkEnableOption "Use Hyprland from nixpkgs";
    enable-plugins = mkEnableOption "Enable Hyprland plugins";
    mpvpaper = mkEnableOption "Enable video wallpapers with mpvpaper";
    hyprpaper = mkEnableOption "Enable image wallpapers with hyprpaper";
    wlogout = mkEnableOption "Enable power options menu";
    hyprlock = mkEnableOption "Enable locking program";
    rofi = mkEnableOption "Enable rofi (used as applauncher and dmenu)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprshot
      pulseaudio
      nautilus
      file-roller
      cliphist
      libnotify
      swappy
      brightnessctl
      imv
      myxer
      ffmpegthumbnailer
      bun
      esbuild
      fd
      dart-sass
      swww
      hyprpicker
      wttrbar
    ];
    wayland.windowManager.hyprland = {
      package = mkMerge [
        (mkIf (!cfg.stable && !cfg.from-unstable) inputs.hyprland.packages.${pkgs.system}.hyprland)
        (mkIf (cfg.from-unstable && !cfg.stable) inputs.unstable.legacyPackages.${pkgs.system}.hyprland)
      ];
      plugins =
        lib.optionals (cfg.enable-plugins && cfg.stable && !cfg.from-unstable) [
          pkgs.hyprlandPlugins.hyprtrails
        ]
        ++ lib.optionals (cfg.enable-plugins && !cfg.stable && !cfg.from-unstable) [
          inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
        ]
        ++ lib.optionals (cfg.enable-plugins && !cfg.stable && cfg.from-unstable) [
          inputs.unstable.legacyPackages.${pkgs.system}.hyprlandPlugins.hyprtrails
        ];
      enable = true;
      settings = {
        "$mod" = "SUPER";
        "$shiftMod" = "SUPER_SHIFT";
        monitor = [", preferred, auto, 1"];
        windowrule = [
          "nomaxsize, class:^(polkit-gnome-authentication-agent-1)$"
          "pin, class:^(polkit-gnome-authentication-agent-1)$"
          "fullscreenstate 0 2, class:(firefox), title:^(.*Discord.* — Mozilla Firefox.*)$"
          "opacity 0.99 override 0.99 override, title:^(QDiskInfo)$"
          "opacity 0.99 override 0.99 override, title:^(MainPicker)$"
          "opacity 0.99 override 0.99 override, class:^(spotify)$"
          "opacity 0.99 override 0.99 override, class:^(org.prismlauncher.PrismLauncher)$"
          "opacity 0.99 override 0.99 override, class:^(mpv)$"
          "opacity 0.99 override 0.99 override, class:^(org.qbittorrent.qBittorrent)$"
        ];
        layerrule = [
          "blur, waybar"
          "blur, rofi"
          "blur, wofi"
          "blur, launcher"
          "blur, logout_dialog"
          "blur, notifications"
          "blur, gtk-layer-shell"
          "blur, swaync-control-center"
          "blur, swaync-notification-window"
          "blurpopups, .*"
          "noanim, selection"
          "noanim, hyprpicker"
          "ignorealpha 0.9, selection"
          "ignorezero, corner0"
          "ignorezero, overview"
          "ignorezero, indicator0"
          "ignorezero, datemenu"
          "ignorezero, launcher"
          "ignorezero, quicksettings"
          "ignorezero, swaync-control-center"
          "ignorezero, rofi"
          "ignorezero, waybar"
          "ignorezero, swaync-notification-window"
          "animation popin 90%, rofi"
          "animation popin 90%, logout_dialog"
          "animation slide left, swaync-control-center"
        ];
        exec-once = [
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "hyprctl setcursor Bibata-Modern-Classic 24"
        ];
        input = {
          kb_layout = "us,ru";
          kb_options = "grp:alt_shift_toggle";
          repeat_delay = 200;
          follow_mouse = 1;
          touchpad = {
            natural_scroll = false;
          };
          sensitivity = 1;
          accel_profile = "flat";
        };
        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 0;
          "col.active_border" = "rgb(4575da) rgb(6804b5)";
          "col.inactive_border" = "rgb(595959)";
          layout = "dwindle";
          allow_tearing = false;
        };
        debug = {
          full_cm_proto = true;
          enable_stdout_logs = false;
          disable_logs = true;
        };
        cursor = {
          no_hardware_cursors = false;
        };
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            popups = true;
            popups_ignorealpha = 0.09;
            ignore_opacity = true;
            size = 10;
            brightness = 0.8;
            passes = 4;
            noise = 0;
            vibrancy = 0;
          };
        };
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        gestures = {
          workspace_swipe = true;
        };
        misc = {
          disable_hyprland_logo = true;
          background_color = "0x000000";
          enable_swallow = true;
          animate_manual_resizes = false;
          animate_mouse_windowdragging = false;
          swallow_regex = "^(kitty|lutris|bottles|alacritty)$";
          swallow_exception_regex = "^(ncspot)$";
          force_default_wallpaper = 2;
        };
        binds = {
          scroll_event_delay = 50;
        };
        plugin = mkIf cfg.enable-plugins {
          hyprexpo = {
            columns = 3;
            gap_size = 5;
            bg_col = "rgb(111111)";
            workspace_method = "first 1";
            enable_gesture = true;
            gesture_distance = 300;
            gesture_positive = true;
          };
          dynamic-cursors = {
            enabled = false;
            mode = "tilt";
            shake.enabled = false;
            stretch.function = "negative_quadratic";
          };
          hyprtrails = {
            color = "rgba(bbddffff)";
            bezier_step = 0.001;
            history_points = 6;
            points_per_step = 4;
            histoty_step = 1;
          };
        };
      };
      extraConfig = ''
        submap=passthrough
          bind=,escape,submap,reset
        submap=reset
      '';
    };

    programs.hyprlock = mkIf cfg.hyprlock {
      enable = true;
      settings = {
        background = [
          {
            monitor = "";
            color = "rgba(0, 0, 0, 0.7)";
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "200, 50";
            outline_thickness = 1;
            dots_size = 0.2;
            dots_spacing = 0.15;
            dots_center = true;
            outer_color = "rgb(000000)";
            inner_color = "rgb(100, 100, 100)";
            font_color = "rgb(10, 10, 10)";
            fade_on_empty = true;
            placeholder_text = "<i>Введите пароль...</i>";
            hide_input = false;
            position = "0, -20";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          {
            monitor = "";
            text = "Введите пароль от пользователя $USER $TIME $ATTEMPTS";
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 25;
            font_family = "Noto Sans";
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
    services.hyprpaper = mkIf (cfg.hyprpaper && !cfg.mpvpaper) {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        preload = ["${../../../stuff/wallpaper.jpg}"];
        wallpaper = [
          ",${../../../stuff/wallpaper.jpg}"
        ];
      };
    };
    systemd.user.services.mpvpaper = mkIf (!cfg.hyprpaper && cfg.mpvpaper) {
      Unit = {
        Description = "Play video wallpaper.";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper -s -o 'no-audio loop input-ipc-server=/tmp/mpvpaper-socket hwdec=auto' '*' ${../../../stuff/wallpaper.mp4}";
      };
    };
    programs.rofi = mkIf cfg.rofi {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "JetBrainsMono NF 14";
      theme = ../../../stuff/theme.rasi;
    };
    programs.wlogout = mkIf cfg.wlogout {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "logout";
          action = "hyprctl dispatch exit";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
      style = ''
        * {
          background-image: none;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 16px;
        }
        window {
          background-color: rgba(0, 0, 0, 0);
        }
        button {
            color: #FFFFFF;
            border-style: solid;
            border-radius: 15px;
            border-width: 3px;
            background-color: rgba(0, 0, 0, 0);
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
        }
        button:focus, button:active, button:hover {
          background-color: rgba(0, 0, 0, 0);
          color: #4470D2;
        }
        #lock {
            background-image: image(url("${../../../stuff/lock.png}"));
        }
        #logout {
            background-image: image(url("${../../../stuff/logout.png}"));
        }
        #shutdown {
            background-image: image(url("${../../../stuff/shutdown.png}"));
        }
        #reboot {
            background-image: image(url("${../../../stuff/reboot.png}"));
        }
      '';
    };
  };
}
