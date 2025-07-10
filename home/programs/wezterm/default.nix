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
          -- Resize splits
          {mods="SUPER|CTRL|SHIFT", key="DownArrow", action=wa.AdjustPaneSize{"Down", 10}},
          {mods="SUPER|CTRL|SHIFT", key="LeftArrow", action=wa.AdjustPaneSize{"Left", 10}},
          {mods="SUPER|CTRL|SHIFT", key="RightArrow", action=wa.AdjustPaneSize{"Right", 10}},
          {mods="SUPER|CTRL|SHIFT", key="UpArrow", action=wa.AdjustPaneSize{"Up", 10}},

          -- Custom screen file actions (replace with your plugin if needed)
          {mods="SUPER|CTRL|SHIFT", key="J", action=wa.SendString("copy_screen_file\n")},
          {mods="CTRL|ALT|SHIFT", key="J", action=wa.SendString("open_screen_file\n")},

          -- Split navigation
          {mods="SUPER|CTRL", key="[", action=wa.ActivatePaneDirection("Prev")},
          {mods="SUPER|CTRL", key="]", action=wa.ActivatePaneDirection("Next")},
          {mods="CTRL|ALT", key="DownArrow", action=wa.ActivatePaneDirection("Down")},
          {mods="CTRL|ALT", key="LeftArrow", action=wa.ActivatePaneDirection("Left")},
          {mods="CTRL|ALT", key="RightArrow", action=wa.ActivatePaneDirection("Right")},
          {mods="CTRL|ALT", key="UpArrow", action=wa.ActivatePaneDirection("Up")},

          -- New splits
          {mods="ALT|SHIFT", key="H", action=wa.SplitHorizontal{domain="CurrentPaneDomain"}},
          {mods="ALT|SHIFT", key="J", action=wa.SplitVertical{domain="CurrentPaneDomain"}},
          {mods="ALT|SHIFT", key="K", action=wa.SplitVertical{domain="CurrentPaneDomain"}},
          {mods="ALT|SHIFT", key="L", action=wa.SplitHorizontal{domain="CurrentPaneDomain"}},

          -- Config and UI
          {mods="CTRL|SHIFT", key=",", action=wa.ReloadConfiguration},
          {mods="CTRL|SHIFT", key="Enter", action=wa.TogglePaneZoomState},
          {mods="CTRL|SHIFT", key="Tab", action=wa.ActivateTabRelative(-1)},
          {mods="CTRL|SHIFT", key="PageDown", action=wa.ActivateTabRelative(1)},
          {mods="CTRL|SHIFT", key="PageUp", action=wa.ActivateTabRelative(-1)},
          {mods="CTRL|SHIFT", key="LeftArrow", action=wa.ActivateTabRelative(-1)},
          {mods="CTRL|SHIFT", key="RightArrow", action=wa.ActivateTabRelative(1)},
          {mods="CTRL|SHIFT", key="C", action=wa.CopyTo("Clipboard")},
          {mods="CTRL|SHIFT", key="E", action=wa.SplitVertical{domain="CurrentPaneDomain"}},
          {mods="CTRL|SHIFT", key="I", action=wa.ShowDebugOverlay},
          {mods="CTRL|SHIFT", key="N", action=wa.SpawnWindow},
          {mods="CTRL|SHIFT", key="O", action=wa.SplitHorizontal{domain="CurrentPaneDomain"}},
          {mods="CTRL|SHIFT", key="P", action=wa.ActivateCommandPalette},
          {mods="CTRL|SHIFT", key="Q", action=wa.QuitApplication},
          {mods="CTRL|SHIFT", key="T", action=wa.SpawnTab("CurrentPaneDomain")},
          {mods="CTRL|SHIFT", key="V", action=wa.PasteFrom("Clipboard")},
          {mods="CTRL|SHIFT", key="W", action=wa.CloseCurrentTab{confirm=true}},
          {mods="CTRL|SHIFT", key="Z", action=wa.ToggleFullScreen},

          -- Tab navigation (PARENTHESIS for ActivateTab!)
          {mods="ALT", key="1", action=wa.ActivateTab(0)},
          {mods="ALT", key="2", action=wa.ActivateTab(1)},
          {mods="ALT", key="3", action=wa.ActivateTab(2)},
          {mods="ALT", key="4", action=wa.ActivateTab(3)},
          {mods="ALT", key="5", action=wa.ActivateTab(4)},
          {mods="ALT", key="6", action=wa.ActivateTab(5)},
          {mods="ALT", key="7", action=wa.ActivateTab(6)},
          {mods="ALT", key="8", action=wa.ActivateTab(7)},
          {mods="ALT", key="9", action=wa.ActivateTab(8)},
          {mods="ALT", key="H", action=wa.ActivatePaneDirection("Left")},
          {mods="ALT", key="J", action=wa.ActivatePaneDirection("Down")},
          {mods="ALT", key="K", action=wa.ActivatePaneDirection("Up")},
          {mods="ALT", key="L", action=wa.ActivatePaneDirection("Right")},
          {mods="ALT", key="T", action=wa.SpawnTab("CurrentPaneDomain")},
          {mods="ALT", key="W", action=wa.CloseCurrentPane{confirm=true}},

          -- Font size
          {mods="CTRL", key="=", action=wa.IncreaseFontSize},
          {mods="CTRL", key="+", action=wa.IncreaseFontSize},
          {mods="CTRL", key=",", action=wa.ShowLauncher},
          {mods="CTRL", key="-", action=wa.DecreaseFontSize},
          {mods="CTRL", key="0", action=wa.ResetFontSize},

          -- Window management
          {mods="CTRL", key="Enter", action=wa.ToggleFullScreen},
          {mods="CTRL", key="Tab", action=wa.ActivateTabRelative(1)},
          {mods="CTRL", key="Insert", action=wa.CopyTo("Clipboard")},
          {mods="CTRL", key="PageDown", action=wa.ActivateTabRelative(1)},
          {mods="CTRL", key="PageUp", action=wa.ActivateTabRelative(-1)},
          {mods="CTRL", key="L", action=wa.ClearScrollback("ScrollbackOnly")},

          -- Scrolling and selection
          {mods="SHIFT", key="End", action=wa.ScrollToBottom},
          {mods="SHIFT", key="Home", action=wa.ScrollToTop},
          {mods="SHIFT", key="Insert", action=wa.PasteFrom("PrimarySelection")},
          {mods="SHIFT", key="PageDown", action=wa.ScrollByPage(1)},
          {mods="SHIFT", key="PageUp", action=wa.ScrollByPage(-1)},

          { mods = "CTRL",     key = "e",   action = wa.SplitHorizontal({ args = { "zsh" } }) },
          { mods = "CTRL",     key = "q",   action = wa.SplitVertical({ args = { "zsh" } }) },
          { mods = "CTRL",     key = "h",   action = wa.ActivatePaneDirection("Left") },
          { mods = "CTRL",     key = "l",   action = wa.ActivatePaneDirection("Right") },
          { mods = "CTRL",     key = "k",   action = wa.ActivatePaneDirection("Up") },
          { mods = "CTRL",     key = "j",   action = wa.ActivatePaneDirection("Down") },
          { mods = "CTRL|ALT", key = "n",   action = wa.AdjustPaneSize({ "Left", 1 }) },
          { mods = "CTRL|ALT", key = ",",   action = wa.AdjustPaneSize({ "Down", 1 }) },
          { mods = "CTRL|ALT", key = ".",   action = wa.AdjustPaneSize({ "Up", 1 }) },
          { mods = "CTRL|ALT", key = "/",   action = wa.AdjustPaneSize({ "Right", 1 }) },
          { mods = "ALT",      key = "q",   action = wa.CloseCurrentPane({ confirm = true }) },

          -- Tab related keys
          { mods = "CTRL|ALT", key = "x",   action = wa.CloseCurrentTab({ confirm = true }) },
          { mods = "ALT",      key = "t",   action = wa.SpawnTab("CurrentPaneDomain") },
        }
      }
    '';
  };
}
