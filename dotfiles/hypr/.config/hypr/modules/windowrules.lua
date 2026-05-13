--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful
local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})


-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name = "float-telegram",
    match = {
        class = "org.telegram.desktop",
    },

    float = true,
    center = true,
    size = "700 900",
    workspace = "unset"
})

hl.window_rule({
    name = "float-pavucontrol",
    match = {
        class = "org.pulseaudio.pavucontrol",
    },

    float = true,
    center = true,
    size = "700 500",
})

hl.window_rule({
    name = "fix-android-studio-popups",
    match = {
        class = "jetbrains-studio",
        title = "^win(.*)$",
    },

    no_initial_focus = true,
})

-- Layer rules
hl.layer_rule({
    name = "blur-logout-dialog",
    match = {
        namespace = "logout_dialog",
    },

    blur = true,
})

hl.layer_rule({
    name = "blur-swaync-control-center",
    match = {
        namespace = "swaync-control-center",
    },

    blur = true,
})

hl.layer_rule({
    name = "alpha-swaync-control-center",
    match = {
        namespace = "swaync-control-center",
    },

    ignore_alpha = 0.48,
})

hl.layer_rule({
    name = "blur-swaync-notification-window",

    match = {
        namespace = "swaync-notification-window",
    },

    blur = true,
})

hl.layer_rule({
    name = "alpha-swaync-notification-window",

    match = {
        namespace = "swaync-notification-window",
    },

    ignore_alpha = 0.35,
})

-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
