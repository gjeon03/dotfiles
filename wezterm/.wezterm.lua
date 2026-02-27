local wezterm = require("wezterm")

local config = wezterm.config_builder()
local is_darwin = wezterm.target_triple:find("darwin") ~= nil

-- ─── Font ──────────────────────────────────────────────
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font Mono",
	"JetBrains Mono",
})
config.font_size = 13

-- ─── Window ────────────────────────────────────────────
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.75
config.window_padding = {
	left = 12,
	right = 12,
	top = 12,
	bottom = 12,
}

if is_darwin then
	config.macos_window_background_blur = 20
end

-- ─── Tab bar ───────────────────────────────────────────
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- ─── Scrollback ────────────────────────────────────────
config.scrollback_lines = 10000

-- ─── Colors (Tokyo Night) ──────────────────────────────
config.color_scheme = "Tokyo Night"

return config
