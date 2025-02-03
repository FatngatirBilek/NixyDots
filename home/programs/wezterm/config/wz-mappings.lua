---@type Wezterm
local wezterm = require("wezterm")
---@type Action
local wa = wezterm.action

local keys = {
    -- Pane related keys
    { key = "e",   mods = "CTRL",               action = wa.SplitHorizontal({ args = { "nu" } }) },
    { key = "q",   mods = "CTRL",               action = wa.SplitVertical({ args = { "nu" } }) },
    { key = "h",   mods = "CTRL",               action = wa.ActivatePaneDirection("Left") },
    { key = "l",   mods = "CTRL",               action = wa.ActivatePaneDirection("Right") },
    { key = "k",   mods = "CTRL",               action = wa.ActivatePaneDirection("Up") },
    { key = "j",   mods = "CTRL",               action = wa.ActivatePaneDirection("Down") },
    { key = "n",   mods = "CTRL|ALT",           action = wa.AdjustPaneSize({ "Left", 1 }) },
    { key = ",",   mods = "CTRL|ALT",           action = wa.AdjustPaneSize({ "Down", 1 }) },
    { key = ".",   mods = "CTRL|ALT",           action = wa.AdjustPaneSize({ "Up", 1 }) },
    { key = "/",   mods = "CTRL|ALT",           action = wa.AdjustPaneSize({ "Right", 1 }) },
    { key = "c",   mods = "ALT",                action = wa.CloseCurrentPane({ confirm = true }) },
    -- Tab related keys
    { key = "x",   mods = "CTRL|ALT",           action = wa.CloseCurrentTab({ confirm = true }) },
    { key = "t",   mods = "ALT",                action = wa.SpawnTab("CurrentPaneDomain") },
    -- Tab navigation
    { key = "Tab", mods = "CTRL",               action = wa.ActivateTabRelative(-1) },
    { key = "Tab", mods = "CTRL|SHIFT",         action = wa.ActivateTabRelative(1) },
    -- Miscelaneous
    { key = "F11", action = wa.ToggleFullScreen },
    { key = "+",   mods = "CTRL",               action = wa.IncreaseFontSize },
    { key = "-",   mods = "CTRL",               action = wa.DecreaseFontSize },
    -- Utilities
    { key = "c",   mods = "CTRL",               action = wa.CopyTo("Clipboard") },
    { key = "v",   mods = "CTRL",               action = wa.PasteFrom("Clipboard") },
    -- Debugging and core functionality
    { key = "d",   mods = "CTRL|ALT",           action = wa.ShowDebugOverlay },
    { key = "p",   mods = "CTRL|SHIFT",         action = wa.ActivateCommandPalette },
}

return keys
