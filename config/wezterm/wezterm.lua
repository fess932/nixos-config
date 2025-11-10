-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
-- config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 20.0
config.font = wezterm.font('FiraCode Nerd Font', { weight = 450, stretch = "Normal", italic = false })
--config.font = wezterm.font 'JetBrains Mono'
-- config.disable_default_mouse_bindings = true

config.window_frame = {
    font_size = 18,
}
--config.window_decorations = "RESIZE"
--config.tab_bar_at_bottom = true
config.color_scheme = "catppuccin-mocha"
config.front_end = "OpenGL"
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
--config.cell_width = 0.9
config.window_background_opacity = 0.99

config.keys = {
    { key = "p",     mods = "SHIFT|SUPER", action = wezterm.action.ActivateCommandPalette },
    { key = "Enter", mods = "SHIFT",       action = wezterm.action { SendString = "\x1b\r" } },
    {
        key = "|",
        mods = "SHIFT|ALT",
        action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
    },
    {
        key = "_",
        mods = "SHIFT|ALT",
        action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
    },
    --      { key = "LeftArrow", mods = "ALT|SHIFT", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
    --      { key = "RightArrow", mods = "ALT|SHIFT", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
    --      { key = "UpArrow", mods = "ALT|SHIFT", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
    --      { key = "DownArrow", mods = "ALT|SHIFT", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
}

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config)

-- and finally, return the configuration to wezterm
return config
