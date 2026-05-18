-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	-- Bar / UI
	hl.exec_cmd("waybar")

	-- Cursor
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 28")

	-- Keyring
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

	-- Polkit agent
	hl.exec_cmd("systemctl --user start hyprpolkitagent")

	-- Clipboard tools
	hl.exec_cmd("wl-clip-persist --clipboard regular")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")

	-- DBus environment sync
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")

	-- Delayed secret check
	hl.exec_cmd("sh -c 'sleep 3 && secret-tool lookup dummy test >/dev/null 2>&1 || true'")

	-- Wallpaper daemon
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("uwsm app -- matuwall --daemon")

	-- Notifications
	hl.exec_cmd("swaync")

	-- RGB control with delay
	hl.exec_cmd("sh -c 'sleep 4 && openrgb --startminimized --profile Black'")
end)
