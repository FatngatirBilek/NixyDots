# Hyprland home-manager configuration
# Adapted from https://github.com/karol-broda/nixos-config
# Keeps user's Bibata-Modern-Ice cursor, uses ghostty terminal, nautilus file manager
{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    # Use the system-installed hyprland package so the binary is in the user
    # profile PATH — required by UWSM's env-preloader to find "hyprland".
    package = pkgs.hyprland;
    portalPackage = null;
    # UWSM handles all systemd session integration; disable HM's own systemd unit.
    systemd.enable = false;

    settings = {
      # ─── Catppuccin Frappé accent palette (dark-mode friendly) ───────────────
      "$rosewater" = "rgb(f2d5cf)";
      "$rosewaterAlpha" = "f2d5cf";
      "$flamingo" = "rgb(eebebe)";
      "$flamingoAlpha" = "eebebe";
      "$pink" = "rgb(f4b8e4)";
      "$pinkAlpha" = "f4b8e4";
      "$mauve" = "rgb(ca9ee6)";
      "$mauveAlpha" = "ca9ee6";
      "$red" = "rgb(e78284)";
      "$redAlpha" = "e78284";
      "$maroon" = "rgb(ea999c)";
      "$maroonAlpha" = "ea999c";
      "$peach" = "rgb(ef9f76)";
      "$peachAlpha" = "ef9f76";
      "$yellow" = "rgb(e5c890)";
      "$yellowAlpha" = "e5c890";
      "$green" = "rgb(a6d189)";
      "$greenAlpha" = "a6d189";
      "$teal" = "rgb(81c8be)";
      "$tealAlpha" = "81c8be";
      "$sky" = "rgb(99d1db)";
      "$skyAlpha" = "99d1db";
      "$sapphire" = "rgb(85c1dc)";
      "$sapphireAlpha" = "85c1dc";
      "$blue" = "rgb(8caaee)";
      "$blueAlpha" = "8caaee";
      "$lavender" = "rgb(babbf1)";
      "$lavenderAlpha" = "babbf1";
      "$text" = "rgb(c6d0f5)";
      "$textAlpha" = "c6d0f5";
      "$subtext1" = "rgb(b5bfe2)";
      "$subtext1Alpha" = "b5bfe2";
      "$subtext0" = "rgb(a5adce)";
      "$subtext0Alpha" = "a5adce";
      "$overlay2" = "rgb(949cbb)";
      "$overlay2Alpha" = "949cbb";
      "$overlay1" = "rgb(838ba7)";
      "$overlay1Alpha" = "838ba7";
      "$overlay0" = "rgb(737994)";
      "$overlay0Alpha" = "737994";
      "$surface2" = "rgb(626880)";
      "$surface2Alpha" = "626880";
      "$surface1" = "rgb(51576d)";
      "$surface1Alpha" = "51576d";
      "$surface0" = "rgb(414559)";
      "$surface0Alpha" = "414559";
      "$base" = "rgb(303446)";
      "$baseAlpha" = "303446";
      "$mantle" = "rgb(292c3c)";
      "$mantleAlpha" = "292c3c";
      "$crust" = "rgb(232634)";
      "$crustAlpha" = "232634";

      # ─── Variables ────────────────────────────────────────────────────────────
      "$terminal" = "ghostty";
      "$fileManager" = "nautilus";
      "$menu" = "wofi --show drun";
      "$mainMod" = "SUPER";
      "$shiftMainMod" = "SUPER SHIFT";

      # ─── Monitor ─────────────────────────────────────────────────────────────
      # Monitor rules are matched top-to-bottom; the catch-all at the end handles
      # any unknown display (projector, random monitor, etc.) with its native
      # preferred resolution automatically — no manual tweaking needed.
      #
      # To find your home HDMI description, plug it in and run:
      #   hyprctl monitors
      # then copy the full "description" field into the rule below.
      #
      # CHANGEME: replace the desc: value with your actual home HDMI description,
      #           and adjust the resolution/refresh if needed.
      monitor = [
        # Built-in display — 1920x1080 @ 165 Hz, always on the left
        "eDP-1, 1920x1080@165, 0x0, 1"

        # Home HDMI monitor (HKC 24E4 on HDMI-A-1) — matched by unique hardware
        # description so it only activates for THIS physical monitor, never a
        # projector or random screen. Positioned to the right of eDP-1 @ 144 Hz.
        "desc:HKC OVERSEAS LIMITED 24E4 0000000000001, 1920x1080@144, 1920x0, 1"

        # Fallback: any other display (projector, guest monitor, …) gets its
        # own preferred/native resolution placed automatically. Safe by default.
        ", preferred, auto, 1, mirror, eDP-1"
      ];

      # ─── Environment variables ────────────────────────────────────────────────
      # With UWSM, all env vars are set via systemd.user.sessionVariables below
      # (written to ~/.config/environment.d/) so that every app launched through
      # `uwsm app` (transient systemd units) inherits them. Hyprland's `env`
      # block is NOT inherited by UWSM-managed processes, so nothing belongs here.

      # ─── Permissions ─────────────────────────────────────────────────────────
      "ecosystem:enforce_permissions" = true;
      permission = [
        ".*quickshell.*, screencopy, allow"
        ".*grim.*, screencopy, allow"
      ];

      # ─── Autostart ───────────────────────────────────────────────────────────
      # Long-running daemons must be wrapped with `uwsm app --` so UWSM tracks
      # them in proper systemd scope/transient units. Without this they become
      # unmanaged children of the compositor and won't be cleaned up on logout.
      exec-once = [
        # Clipboard history (cliphist for quickshell/elephant clipboard provider)
        "uwsm app -- wl-paste --type text --watch cliphist store"
        "uwsm app -- wl-paste --type image --watch cliphist store"
      ];

      # ─── General ─────────────────────────────────────────────────────────────
      general = {
        gaps_in = 6;
        gaps_out = 18;
        border_size = 3;
        "col.active_border" = "$lavender $mauve 45deg";
        "col.inactive_border" = "rgba(737994aa)";
        layout = "dwindle";
        resize_on_border = false;
        allow_tearing = false;
      };

      # ─── Decoration ──────────────────────────────────────────────────────────
      decoration = {
        rounding = 12;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          color = "rgba(00000055)";
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          ignore_opacity = false;
          vibrancy = 0.12;
        };
      };

      # ─── Animations ─────────────────────────────────────────────────────────
      animations = {
        enabled = true;

        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];

        animation = [
          "windows, 1, 7, myBezier"
          "windowsIn, 1, 7, myBezier, slide"
          "windowsOut, 1, 7, myBezier, slide"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, myBezier, slide"
        ];
      };

      # ─── Layouts ─────────────────────────────────────────────────────────────
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = true;
        force_split = 2;
      };

      master = {
        new_status = "master";
        center_master_fallback = "right";
      };

      # ─── Misc ────────────────────────────────────────────────────────────────
      misc = {
        disable_hyprland_logo = true;
        vfr = true;
        focus_on_activate = true;
      };

      # ─── Input ───────────────────────────────────────────────────────────────
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
          clickfinger_behavior = true;
        };
      };

      cursor = {
        hide_on_key_press = false;
      };

      # 3-finger horizontal swipe switches workspaces
      gesture = [
        "3, horizontal, workspace"
      ];

      # ─── Keybinds ────────────────────────────────────────────────────────────
      # GUI apps use `uwsm app --` so UWSM launches them as transient systemd
      # units with proper cgroup tracking, env inheritance, and clean shutdown.
      # One-shot / instant commands (killactive, wpctl, etc.) do NOT need it.
      bind = [
        # Core
        "$mainMod, T, exec, uwsm app -- $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, E, exec, uwsm app -- $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreenstate, 1 1"
        "$shiftMainMod, F, fullscreenstate, 2"
        "$mainMod, R, exec, uwsm app -- $menu"
        "$mainMod, space, layoutmsg, togglesplit"

        # Quickshell panels (global shortcuts registered by the shell)
        "$mainMod, D, global, quickshell:launcher"
        "$mainMod, L, global, quickshell:lock"

        # Screenshots via quickshell
        ", Print, global, quickshell:screenshot"
        "SHIFT, Print, global, quickshell:screenshotFreeze"
        "SUPER, Print, global, quickshell:screenshot"
        "SUPER SHIFT, Print, global, quickshell:screenshotFreeze"

        # Focus movement (arrow keys + HJKL)
        "$mainMod, left,  movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up,    movefocus, u"
        "$mainMod, down,  movefocus, d"
        "$mainMod, H, movefocus, l"
        "$mainMod, J, movefocus, d"
        "$mainMod, K, movefocus, u"
        "$mainMod, L, movefocus, r"

        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace
        "$shiftMainMod, 1, movetoworkspace, 1"
        "$shiftMainMod, 2, movetoworkspace, 2"
        "$shiftMainMod, 3, movetoworkspace, 3"
        "$shiftMainMod, 4, movetoworkspace, 4"
        "$shiftMainMod, 5, movetoworkspace, 5"
        "$shiftMainMod, 6, movetoworkspace, 6"
        "$shiftMainMod, 7, movetoworkspace, 7"
        "$shiftMainMod, 8, movetoworkspace, 8"
        "$shiftMainMod, 9, movetoworkspace, 9"
        "$shiftMainMod, 0, movetoworkspace, 10"

        # Multi-monitor
        "$mainMod, period,      focusmonitor, +1"
        "$mainMod, comma,       focusmonitor, -1"
        "$shiftMainMod, period, movecurrentworkspacetomonitor, +1"
        "$shiftMainMod, comma,  movecurrentworkspacetomonitor, -1"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$shiftMainMod, S, movetoworkspace, special:magic"

        # Scroll through workspaces with mousewheel
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up,   workspace, e-1"

        # Window swapping (HJKL with shift)
        "$shiftMainMod, H, swapwindow, l"
        "$shiftMainMod, J, swapwindow, d"
        "$shiftMainMod, K, swapwindow, u"
        "$shiftMainMod, L, swapwindow, r"

        # Window resize (HJKL with ctrl)
        "$mainMod CTRL, H, resizeactive, -30 0"
        "$mainMod CTRL, L, resizeactive, 30 0"
        "$mainMod CTRL, J, resizeactive, 0 30"
        "$mainMod CTRL, K, resizeactive, 0 -30"

        # Window move when floating (HJKL with ctrl+shift)
        "$shiftMainMod CTRL, H, moveactive, -40 0"
        "$shiftMainMod CTRL, L, moveactive, 40 0"
        "$shiftMainMod CTRL, J, moveactive, 0 40"
        "$shiftMainMod CTRL, K, moveactive, 0 -40"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Volume / brightness (with repeat)
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute,     exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp,   exec, brightnessctl -e4 -n2 set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      # Media keys (passthrough even when screen is locked)
      bindl = [
        ", XF86AudioNext,  exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay,  exec, playerctl play-pause"
        ", XF86AudioPrev,  exec, playerctl previous"
        # Lid close → suspend system + disable built-in display
        # Lid open  → re-enable built-in display
        '', switch:on:Lid Switch,  exec, systemctl suspend && hyprctl keyword monitor "eDP-1, disable"''
        '', switch:off:Lid Switch, exec, hyprctl keyword monitor "eDP-1, 1920x1080@165, 0x0, 1"''
      ];

      # ─── Window rules ────────────────────────────────────────────────────────
      windowrule = [
        "match:class .*, suppress_event maximize"
        "match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, no_initial_focus on"
        "match:class ^(pavucontrol)$, float on"
        "match:title ^(Picture-in-Picture)$, float on"
        "match:class ^(nwg-look)$, float on"
        "match:class ^(gnome-disk-utility)$, float on"
      ];
    };
  };

  # Polkit agent for hyprland (needed for privilege escalation prompts)
  services.hyprpolkitagent.enable = true;

  # ─── Session-wide environment (environment.d) ────────────────────────────
  # UWSM launches apps as transient systemd user units, so they do NOT inherit
  # Hyprland's `env` block. These vars are written to ~/.config/environment.d/
  # which systemd reads at user-session start — every unit (and `uwsm app`)
  # inherits them automatically.
  #
  # Cursor, toolkit backends, and GTK theming vars that used to live in the
  # Hyprland env block are placed here instead.
  systemd.user.sessionVariables = {
    # Cursor
    HYPRCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    WLR_XCURSOR_THEME = "Bibata-Modern-Ice";
    WLR_XCURSOR_SIZE = "24";

    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_THEME = "Orchis-Dark";
    GTK_APPLICATION_PREFER_DARK_THEME = "1";
  };
}
