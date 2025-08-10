{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib; let
  keyboardLayout = config.var.keyboardLayout;
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
      portalPackage = null;
      package = null;
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      settings = {
        "$mod" = "SUPER";
        "$shiftMod" = "SUPER_SHIFT";
        monitor = [
          "eDP-1, 1920x1080@165, 0x0, 1"
          #", preffered, auto, 1, mirror, eDP-1"
          "HDMI-A-1, 1920x1080@120, 1920x0,1"
        ];
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
          "dbus-update-activation-environment --systemd "
          "nwg-dock-hyprland -r -i 35 -ml 12 -mr 12 -mb 12 -nolauncher -x -l bottom"
          "caelestia-shell"
        ];
        input = {
          kb_layout = keyboardLayout;
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
          # dynamic-cursors = {
          #   enabled = false;
          #   mode = "tilt";
          #   shake.enabled = false;
          #   stretch.function = "negative_quadratic";
          # };
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
    systemd.user.targets.hyprland-session.Unit.Wants = ["xdg-desktop-autostart.target"];

    services.hyprpaper = mkIf (cfg.hyprpaper && !cfg.mpvpaper) {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        preload = ["${inputs.thirr-wallpapers + "/wallpapers/wallpaper.jpg"}"];
        wallpaper = [
          ",${inputs.thirr-wallpapers + "/wallpapers/wallpaper.jpg"}"
        ];
      };
    };
    # systemd.user.services.mpvpaper = mkIf (!cfg.hyprpaper && cfg.mpvpaper) {
    #   Unit = {
    #     Description = "Play video wallpaper.";
    #   };
    #   Install = {
    #     WantedBy = ["graphical-session.target"];
    #   };
    #   Service = {
    #     ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper -s -o 'no-audio loop input-ipc-server=/tmp/mpvpaper-socket hwdec=auto' '*' ${../../../stuff/wallpaper.mp4}";
    #   };
    # };
  };
}
