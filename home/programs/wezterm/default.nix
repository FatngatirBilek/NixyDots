{...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require "wezterm"
      local wa = wezterm.action

      return {
        font = wezterm.font("JetBrainsMono Nerd Font"),
        font_size = 14.0,
        color_scheme = "Catppuccin Mocha",
        window_background_opacity = 0.9,

        colors = {
          tab_bar = {
            background = "#1e1e2e",
            active_tab = {
              bg_color = "#b4befe",
              fg_color = "#1e1e2e",
              intensity = "Bold",
              underline = "None",
              italic = false,
              strikethrough = false,
            },
            inactive_tab = {
              bg_color = "#1e1e2e",
              fg_color = "#cdd6f4",
            },
            inactive_tab_hover = {
              bg_color = "#313244",
              fg_color = "#cdd6f4",
              italic = true,
            },
            new_tab = {
              bg_color = "#1e1e2e",
              fg_color = "#b4befe",
            },
            new_tab_hover = {
              bg_color = "#b4befe",
              fg_color = "#1e1e2e",
              italic = true,
            },
          },
        },

        keys = {
          -- Tab
          {mods="ALT",        key="t", action=wa.SpawnTab("CurrentPaneDomain")},
          {mods="ALT",        key="w", action=wa.CloseCurrentPane{confirm=true}},

          -- Clipboard
          {mods="CTRL|SHIFT", key="C", action=wa.CopyTo("Clipboard")},
          {mods="CTRL|SHIFT", key="V", action=wa.PasteFrom("Clipboard")},

          -- Window decorations (closest WezTerm equivalent)
          {mods="CTRL|SHIFT", key="Z", action=wa.ToggleFullScreen},

          -- Clear screen
          {mods="CTRL",       key="l", action=wa.ClearScrollback("ScrollbackOnly")},

          -- Navigate splits (alt+h/j/k/l)
          {mods="ALT",        key="h", action=wa.ActivatePaneDirection("Left")},
          {mods="ALT",        key="j", action=wa.ActivatePaneDirection("Down")},
          {mods="ALT",        key="k", action=wa.ActivatePaneDirection("Up")},
          {mods="ALT",        key="l", action=wa.ActivatePaneDirection("Right")},

          -- New splits (alt+shift+h/j/k/l)
          {mods="ALT|SHIFT",  key="H", action=wa.SplitPane{direction="Left"}},
          {mods="ALT|SHIFT",  key="J", action=wa.SplitPane{direction="Down"}},
          {mods="ALT|SHIFT",  key="K", action=wa.SplitPane{direction="Up"}},
          {mods="ALT|SHIFT",  key="L", action=wa.SplitPane{direction="Right"}},
        }
      }
    '';
  };
}
