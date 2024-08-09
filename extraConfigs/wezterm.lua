-- local wezterm = require("wezterm")  -- this gets autogenerated by home-manager
local config = {}

config.color_scheme = "Ayu Mirage"
config.font = wezterm.font_with_fallback({"FiraCode Nerd Font Mono","JetBrainsMono Nerd Font Mono"})
config.font_size = 13

config.window_close_confirmation = "NeverPrompt"
config.initial_rows = 60
config.initial_cols = 150

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.adjust_window_size_when_changing_font_size = false
config.use_fancy_tab_bar = true

config.audible_bell = "Disabled"

return config