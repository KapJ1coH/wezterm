-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

config.default_prog = { "nu", "-l" }

-- Quick launch menu so you can pick shells from the window menu
config.launch_menu = {
  { label = "Nushell (login)", args = { "nu", "-l" } },
  { label = "Bash (login)",    args = { "/usr/bin/bash", "-l" } },
}

config.window_background_opacity = 80

config.use_fancy_tab_bar = true

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- Fonts
config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",
  "FiraCode Nerd Font",
  "Noto Color Emoji",
})
config.font_size = 12

-- Colors & transparency
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.8
config.text_background_opacity = 0.8
config.window_close_confirmation = 'NeverPrompt'
config.max_fps = 120


config.audible_bell = "Disabled"

config.window_decorations = "RESIZE"


-- trying to fix nvim's <C-S-Left/right> not being detected
config.enable_csi_u_key_encoding = true

-- Keybindings
config.keys = {
    -- Copy/Paste (no Shift circus)
    { key = "C", mods = "CTRL", action = act.CopyTo("Clipboard") },
    { key = "V", mods = "CTRL", action = act.PasteFrom("Clipboard") },

    -- Fullscreen
    { key = "F11", mods = "NONE", action = act.ToggleFullScreen },

    -- Splits
    { key = "D", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "D", mods = "CTRL|ALT",   action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Tabs
    { key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "N", mods = "CTRL|SHIFT", action = act.SpawnWindow },

    -- Tab switching with Ctrl+Arrow
    { key = "RightArrow", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "LeftArrow",  mods = "CTRL", action = act.ActivateTabRelative(-1) },

    -- Quick spawns
    { key = "U", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({ args = { "nu", "-l" } }) },
    { key = "B", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({ args = { "/usr/bin/bash", "-l" } }) },

    -- Launcher for when you forget the shortcuts
    { key = "L", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS" }) },

    -- vim specific
    {
        key = "RightArrow",
        mods = "SHIFT|CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
    {
        key = "LeftArrow",
        mods = "SHIFT|CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },



}

return config

