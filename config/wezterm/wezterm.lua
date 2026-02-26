-- Pull in the wezterm API
local wezterm = require 'wezterm'

local config = wezterm.config_builder()
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")

-- This will hold the configuration.
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():toggle_fullscreen()
end)
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

bar.apply_to_config(config)

wezterm.on('window-config-reloaded', function(window, pane)
    wezterm.log_info("window reload сработал!")
    window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
end)

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

    {
        key = "F8",
        mods = "",
        action = wezterm.action_callback(function(win, pane)
            wezterm.log_info("ALT+w сработал!")
            win:toast_notification("wezterm", "⌥+w сработал!", nil, 2000)
        end),
    },
}

-- local act = wezterm.action
local sessions = wezterm.plugin.require("https://github.com/abidibo/wezterm-sessions")
-- Optional: adds default keybindings and plugin configuration
-- a+ALT = toggle_autosave
-- s+ALT = save_session
-- l+ALT = load_session
-- r+ALT = restore_session
-- d+CTRL|SHIFT = delete_session
sessions.apply_to_config(config, {
    auto_save_interval_s = 30,
})


-- автозагрузка при старте
local restored = false
wezterm.on("window-focus-changed", function(window, pane)
    if not restored then
        restored = true
        window:perform_action(wezterm.action({ EmitEvent = "restore_session" }), pane)
    end
end)

-- and finally, return the configuration to wezterm
return config
