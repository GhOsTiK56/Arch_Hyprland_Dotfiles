-----------------------------------
---- MY PROGRAMS & KEYBINDINGS ----
-----------------------------------
-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more

local terminal = "kitty"
local fileManager = "kitty -e yazi"
local browser = "zen-browser"
local messenger = "Telegram"
local note = "obsidian"
local wlogout = "wlogout"
local hyprlock = "hyprlock"
local wallpaper = "matuwall --toggle"
local wallpaper_reset = "matuwall --reload"
local menu = "rofi -show drun"
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Applications
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(messenger))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(note))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(wallpaper))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(wallpaper_reset))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(wlogout))

-- Window Managment
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd(hyprlock))

-- Clipboard history
hl.bind(
	mainMod .. " + SHIFT + V",
	hl.dsp.exec_cmd(
		[[sh -c 'cliphist list | rofi -dmenu -i -p "📋 Clipboard History" -theme-str "window {width: 700px;}" | cliphist decode | wl-copy']]
	)
)

-- Screenshots
-- Print -> quick screenshot
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -zm region --freeze --raw | wl-copy -t image/png"))

-- SUPER + Print -> screenshot with satty editor
hl.bind(
	mainMod .. " + PRINT",
	hl.dsp.exec_cmd(
		[[sh -c 'hyprshot -zm region --freeze --raw | satty --filename - --early-exit --copy-command="wl-copy -t image/png" --actions-on-enter=save-to-clipboard']]
	)
)

-- Focus movement
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Relative workspace switching
hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ workspace = "r+1" }))

-- Mouse binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
