# Hyprland home-manager configuration
# Fully migrated to native Hyprland Lua API via extraLuaFiles
#
# References:
#   https://wiki.hypr.land/nix/configuring-hyprland-with-home-manager/
#   https://nix-community.github.io/home-manager/options/home-manager/wayland.html#opt-wayland.windowManager.hyprland.enable
{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = null;
    systemd.enable = false;
    configType = "lua";

    # Leave settings empty so Home Manager doesn't generate invalid
    # hl.<attribute>() calls (e.g. hl.ecosystem, hl.windowrule, etc.)
    settings = {};

    extraLuaFiles = {
      # ── config.lua: Monitors, Look & Feel, Ecosystem, Animations ──────────
      "config" = {
        autoLoad = true;
        content = ''
          -- ────────────────────────────────────────────────────────────────────
          -- MONITORS
          -- ────────────────────────────────────────────────────────────────────
          hl.monitor({
              output   = "eDP-1",
              mode     = "1920x1080@165",
              position = "0x0",
              scale    = 1,
          })
          hl.monitor({
              output   = "desc:HKC OVERSEAS LIMITED 24E4 0000000000001",
              mode     = "1920x1080@144",
              position = "1920x0",
              scale    = 1,
          })
          hl.monitor({
              output   = "",
              mode     = "preferred",
              position = "auto",
              scale    = 1,
              mirror   = "eDP-1",
          })

          -- ────────────────────────────────────────────────────────────────────
          -- MAIN CONFIG (hl.config)
          -- ────────────────────────────────────────────────────────────────────
          hl.config({
              ecosystem = {
                  enforce_permissions = true,
              },

              general = {
                  gaps_in          = 5,
                  gaps_out         = 5,
                  border_size      = 0,
                  col = {
                      active_border   = "rgba(707070ff)",
                      inactive_border = "rgba(d0d0d0ff)",
                  },
                  layout           = "dwindle",
                  resize_on_border = false,
                  allow_tearing    = true,
              },

              decoration = {
                  rounding       = 12,
                  rounding_power = 2,
                  active_opacity   = 1.0,
                  inactive_opacity = 0.9,

                  shadow = {
                      enabled      = true,
                      range        = 30,
                      render_power = 4,      -- max allowed is 4
                      offset       = { 0, 5 },-- vec2 requires 2-element array
                      color        = 0x70000000,
                  },

                  blur = {
                      enabled        = true,
                      size           = 8,
                      passes         = 2,
                      ignore_opacity = false,
                      vibrancy       = 0.12,
                  },
              },

              animations = {
                  enabled = true,
              },

              dwindle = {
                  preserve_split = true,
                  smart_split    = true,
                  force_split    = 2,
              },

              master = {
                  new_status             = "master",
                  center_master_fallback = "right",
              },

              misc = {
                  disable_hyprland_logo = true,
                  focus_on_activate     = true,
              },

              input = {
                  kb_layout    = "us",
                  follow_mouse = 1,
                  sensitivity  = 0,
                  touchpad = {
                      natural_scroll        = true,
                      disable_while_typing  = true,
                      tap_to_click          = true,
                      clickfinger_behavior  = true,
                  },
              },

              cursor = {
                  hide_on_key_press = false,
              },
          })

          -- ────────────────────────────────────────────────────────────────────
          -- ANIMATIONS
          -- ────────────────────────────────────────────────────────────────────
          hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

          hl.animation({ leaf = "windows",    enabled = true, speed = 7, bezier = "myBezier" })
          hl.animation({ leaf = "windowsIn",  enabled = true, speed = 7, bezier = "myBezier", style = "slide" })
          hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "myBezier", style = "slide" })
          hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
          hl.animation({ leaf = "borderangle",enabled = true, speed = 8,  bezier = "default" })
          hl.animation({ leaf = "fade",       enabled = true, speed = 7,  bezier = "default" })
          hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "myBezier", style = "slide" })
        '';
      };

      # ── rules.lua: Permissions and Window Rules ───────────────────────────
      "rules" = {
        autoLoad = true;
        content = ''
          -- ────────────────────────────────────────────────────────────────────
          -- PERMISSIONS
          -- ────────────────────────────────────────────────────────────────────
          hl.permission(".*grim.*", "screencopy", "allow")
          hl.permission(".*slurp.*", "screencopy", "allow")
          hl.permission(".*wayfreeze.*", "screencopy", "allow")
          hl.permission(".*noctalia.*", "screencopy", "allow")

          -- ────────────────────────────────────────────────────────────────────
          -- WINDOW RULES
          -- ────────────────────────────────────────────────────────────────────
          hl.window_rule({
              name  = "suppress-maximize",
              match = { class = ".*" },
              suppress_event = "maximize",
          })

          hl.window_rule({
              name  = "fix-xwayland-drags",
              match = {
                  class      = "^$",
                  title      = "^$",
                  xwayland   = true,
                  float      = true,
                  fullscreen = false,
              },
              no_focus = true,
          })

          hl.window_rule({
              name  = "unfocused-opacity",
              match = { float = false, focus = false },
              opacity = "0.9 0.9",
          })

          hl.window_rule({
              name  = "gnome-border",
              match = { class = "^(org\\.gnome\\.)" },
              rounding    = 12,
              border_size = 0,
          })

          hl.window_rule({
              name  = "terminals-border",
              match = { class = "^(org\\.wezfurlong\\.wezterm|Alacritty|zen|com\\.mitchellh\\.ghostty|kitty)$" },
              border_size = 0,
          })

          hl.window_rule({
              name  = "floating-utilities",
              match = { class = "^(gnome-calculator|blueman-manager|org\\.gnome\\.Nautilus|pavucontrol|nwg-look|gnome-disk-utility)$" },
              float = true,
          })

          hl.window_rule({
              name  = "picture-in-picture",
              match = { title = "^(Picture-in-Picture)$" },
              float = true,
          })

          hl.window_rule({
              name  = "noctalia-panel",
              match = { class = "^(dev\\.noctalia\\.Noctalia)$" },
              float = true,
              size  = { 1080, 920 },
          })
        '';
      };

      # ── bindings.lua: Keybindings, Mouse Binds, Autostart ─────────────────
      "bindings" = {
        autoLoad = true;
        content = ''
          -- ────────────────────────────────────────────────────────────────────
          -- BINDINGS
          -- ────────────────────────────────────────────────────────────────────
          local mainMod  = "SUPER"
          local terminal = "wezterm"
          local fileManager = "nautilus"
          local menu     = "wofi --show drun"

          -- ── Autostart ─────────────────────────────────────────────────────
          hl.on("hyprland.start", function()
              hl.exec_cmd("uwsm app -- wl-clip-persist --clipboard regular")
          end)

          -- ── 3-finger swipe ────────────────────────────────────────────────
          hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

          -- ── Core ──────────────────────────────────────────────────────────
          hl.bind(mainMod .. " + T",             hl.dsp.exec_cmd("uwsm app -- " .. terminal))
          hl.bind(mainMod .. " + Q",             hl.dsp.window.close())
          hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd("uwsm app -- " .. fileManager))
          hl.bind(mainMod .. " + SHIFT + V",     hl.dsp.window.float({ action = "toggle" }))
          hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
          hl.bind(mainMod .. " + SHIFT + F",     hl.dsp.window.fullscreen({ mode = "maximized" }))
          hl.bind(mainMod .. " + R",             hl.dsp.exec_cmd("uwsm app -- " .. menu))
          hl.bind(mainMod .. " + space",         hl.dsp.layout("togglesplit"))

          -- ── Screenshot ────────────────────────────────────────────────────
          hl.bind("Print",                       hl.dsp.exec_cmd("screenshot"))

          -- ── Noctalia ──────────────────────────────────────────────────────
          hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
          hl.bind(mainMod .. " + V",             hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
          hl.bind(mainMod .. " + comma",         hl.dsp.exec_cmd("noctalia msg settings-toggle"))
          hl.bind(mainMod .. " + N",             hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
          hl.bind(mainMod .. " + Y",             hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"))
          hl.bind(mainMod .. " + TAB",           hl.dsp.exec_cmd("noctalia msg window-switcher"))
          hl.bind(mainMod .. " + P",             hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
          hl.bind(mainMod .. " + ALT + L",       hl.dsp.exec_cmd("noctalia msg session lock"))

          -- ── Focus (arrow keys + HJKL) ─────────────────────────────────────
          hl.bind(mainMod .. " + left",          hl.dsp.focus({ direction = "left"  }))
          hl.bind(mainMod .. " + right",         hl.dsp.focus({ direction = "right" }))
          hl.bind(mainMod .. " + up",            hl.dsp.focus({ direction = "up"    }))
          hl.bind(mainMod .. " + down",          hl.dsp.focus({ direction = "down"  }))
          hl.bind(mainMod .. " + H",             hl.dsp.focus({ direction = "left"  }))
          hl.bind(mainMod .. " + J",             hl.dsp.focus({ direction = "down"  }))
          hl.bind(mainMod .. " + K",             hl.dsp.focus({ direction = "up"    }))
          hl.bind(mainMod .. " + L",             hl.dsp.focus({ direction = "right" }))

          -- ── Workspaces 1-10 ───────────────────────────────────────────────
          for i = 1, 10 do
              local key = i % 10  -- 10 → key 0
              hl.bind(mainMod .. " + " .. key,               hl.dsp.focus({ workspace = i }))
              hl.bind(mainMod .. " + SHIFT + " .. key,       hl.dsp.window.move({ workspace = i }))
          end

          -- ── Multi-monitor ─────────────────────────────────────────────────
          hl.bind(mainMod .. " + period",                    hl.dsp.focus({ monitor = "+1" }))
          hl.bind(mainMod .. " + SHIFT + period",            hl.dsp.workspace.move({ monitor = "+1" }))
          hl.bind(mainMod .. " + SHIFT + comma",             hl.dsp.workspace.move({ monitor = "-1" }))

          -- ── Special workspace (scratchpad) ────────────────────────────────
          hl.bind(mainMod .. " + S",                         hl.dsp.workspace.toggle_special("magic"))
          hl.bind(mainMod .. " + SHIFT + S",                 hl.dsp.window.move({ workspace = "special:magic" }))

          -- ── Mouse scroll through workspaces ───────────────────────────────
          hl.bind(mainMod .. " + mouse_down",                hl.dsp.focus({ workspace = "e+1" }))
          hl.bind(mainMod .. " + mouse_up",                  hl.dsp.focus({ workspace = "e-1" }))

          -- ── Window swap (SUPER + SHIFT + HJKL) ───────────────────────────
          hl.bind(mainMod .. " + SHIFT + H",                 hl.dsp.window.swap({ direction = "left"  }))
          hl.bind(mainMod .. " + SHIFT + J",                 hl.dsp.window.swap({ direction = "down"  }))
          hl.bind(mainMod .. " + SHIFT + K",                 hl.dsp.window.swap({ direction = "up"    }))
          hl.bind(mainMod .. " + SHIFT + L",                 hl.dsp.window.swap({ direction = "right" }))

          -- ── Window resize (SUPER + CTRL + HJKL) ──────────────────────────
          hl.bind(mainMod .. " + CTRL + H",                  hl.dsp.window.resize({ x = -30, y =   0, relative = true }))
          hl.bind(mainMod .. " + CTRL + L",                  hl.dsp.window.resize({ x =  30, y =   0, relative = true }))
          hl.bind(mainMod .. " + CTRL + J",                  hl.dsp.window.resize({ x =   0, y =  30, relative = true }))
          hl.bind(mainMod .. " + CTRL + K",                  hl.dsp.window.resize({ x =   0, y = -30, relative = true }))

          -- ── Floating window move (SUPER + CTRL + SHIFT + HJKL) ───────────
          hl.bind(mainMod .. " + CTRL + SHIFT + H",          hl.dsp.window.move({ x = -40, y =   0, relative = true }))
          hl.bind(mainMod .. " + CTRL + SHIFT + L",          hl.dsp.window.move({ x =  40, y =   0, relative = true }))
          hl.bind(mainMod .. " + CTRL + SHIFT + J",          hl.dsp.window.move({ x =   0, y =  40, relative = true }))
          hl.bind(mainMod .. " + CTRL + SHIFT + K",          hl.dsp.window.move({ x =   0, y = -40, relative = true }))

          -- ── Mouse drag / resize ───────────────────────────────────────────
          hl.bind(mainMod .. " + mouse:272",                 hl.dsp.window.drag(),   { mouse = true })
          hl.bind(mainMod .. " + mouse:273",                 hl.dsp.window.resize(), { mouse = true })

          -- ── Multimedia ────────────────────────────────────────────────────
          hl.bind("XF86AudioPlay",    hl.dsp.exec_cmd("playerctl play-pause"))
          hl.bind("XF86AudioNext",    hl.dsp.exec_cmd("playerctl next"))
          hl.bind("XF86AudioPrev",    hl.dsp.exec_cmd("playerctl previous"))

          -- ── Volume (locked + repeating) ───────────────────────────────────
          hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"),
              { locked = true, repeating = true })
          hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"),
              { locked = true, repeating = true })

          -- ── Locked keys ───────────────────────────────────────────────────
          hl.bind("XF86AudioMute",
              hl.dsp.exec_cmd("noctalia msg volume-mute"),    { locked = true })
          hl.bind("XF86AudioMicMute",
              hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
          hl.bind("XF86MonBrightnessUp",
              hl.dsp.exec_cmd("brightness-up"),               { locked = true })
          hl.bind("XF86MonBrightnessDown",
              hl.dsp.exec_cmd("brightness-down"),             { locked = true })

          -- ── Lid switch ────────────────────────────────────────────────────
          hl.bind("switch:on:Lid Switch",
              hl.dsp.exec_cmd('systemctl suspend && hyprctl keyword monitor "eDP-1, disable"'),
              { locked = true })
          hl.bind("switch:off:Lid Switch",
              hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, 1920x1080@165, 0x0, 1"'),
              { locked = true })
        '';
      };
    };
  };

  services.hyprpolkitagent.enable = true;

  systemd.user.sessionVariables = {
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
