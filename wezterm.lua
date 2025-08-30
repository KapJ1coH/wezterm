-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

config.default_prog = { "/usr/bin/nu", "-l" }

-- Quick launch menu so you can pick shells from the window menu
config.launch_menu = {
  { label = "Nushell (login)", args = { "/usr/bin/nu", "-l" } },
  { label = "Bash (login)",    args = { "/usr/bin/bash", "-l" } },
}

config.window_background_opacity = 80

config.use_fancy_tab_bar = true

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28


-- Colors & transparency
config.font_size = 12
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.8
config.text_background_opacity = 0.8


config.audible_bell = "Disabled"

config.window_decorations = "RESIZE"

return config

