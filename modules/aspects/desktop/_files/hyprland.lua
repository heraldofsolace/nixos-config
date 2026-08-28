-- Variables
local TERMINAL = nix.vars.terminal or "wezterm-gui"
local key = nix.vars.key or "tab"
local mod = nix.vars.mod or "SUPER"
local modifier = nix.vars.modifier or "alt"
local modifier_release = nix.vars.modifier_release or "ALT_L"
local reverse = nix.vars.reverse or "shift"

-- Animations

hl.curve("linear", {
    type = "bezier",
    points = {{0.0, 0.0}, {1.0, 1.0}}
})
hl.curve("md3_standard", {
    type = "bezier",
    points = {{0.2, 0}, {0, 1}}
})
hl.curve("md3_decel", {
    type = "bezier",
    points = {{0.05, 0.7}, {0.1, 1}}
})
hl.curve("md3_accel", {
    type = "bezier",
    points = {{0.3, 0}, {0.8, 0.15}}
})
hl.curve("overshot", {
    type = "bezier",
    points = {{0.05, 0.9}, {0.1, 1.1}}
})
hl.curve("crazyshot", {
    type = "bezier",
    points = {{0.1, 1.5}, {0.76, 0.92}}
})
hl.curve("hyprnostretch", {
    type = "bezier",
    points = {{0.05, 0.9}, {0.1, 1.1}}
})
hl.curve("menu_decel", {
    type = "bezier",
    points = {{0.1, 1}, {0, 1}}
})
hl.curve("menu_accel", {
    type = "bezier",
    points = {{0.38, 0.04}, {1, 0.07}}
})
hl.curve("easeOutBack", {
    type = "bezier",
    points = {{0.34, 1.3}, {0.64, 1}}
})
hl.curve("easeOutExpo", {
    type = "bezier",
    points = {{0.16, 1}, {0.3, 1}}
})
hl.curve("popIn", {
    type = "bezier",
    points = {{0.05, 0.9}, {0.1, 1.05}}
})
hl.curve("softAcDecel", {
    type = "bezier",
    points = {{0.26, 0.26}, {0.15, 1}}
})
hl.curve("md2", {
    type = "bezier",
    points = {{0.4, 0}, {0.2, 1}}
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 8,
    bezier = "md3_decel",
    style = "slide top"
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 8,
    bezier = "md3_standard",
    style = "slide top 0%"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 8,
    bezier = "md3_standard",
    style = "slide top 0%"
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 8,
    bezier = "md3_standard",
    style = "slide top 20%"
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4,
    bezier = "menu_accel",
    style = "slide top 20%"
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 4,
    bezier = "menu_decel",
    style = "slide top 20%"
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 8,
    bezier = "default"
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 8,
    bezier = "default"
})
hl.animation({
    leaf = "fadeSwitch",
    enabled = true,
    speed = 8,
    bezier = "default"
})
hl.animation({
    leaf = "fadeShadow",
    enabled = true,
    speed = 8,
    bezier = "default"
})
hl.animation({
    leaf = "fadeDim",
    enabled = true,
    speed = 8,
    bezier = "default"
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 8,
    bezier = "default"
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 8,
    bezier = "default"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 6,
    bezier = "linear"
})
hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 100,
    bezier = "linear",
    style = "loop"
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 10,
    bezier = "default"
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 8,
    bezier = "default",
    style = "slidevert"
})

local function monitor_set(mon)
    for i = 1, 9 do
        local ws = (mon.id * 9) + i
        hl.workspace_rule({
            workspace = ws,
            monitor = mon.name,
            persistent = true
        })
        hl.dispatch(hl.dsp.workspace.move({
            workspace = ws,
            monitor = mon.name
        }))
    end
    hl.workspace_rule({
        workspace = (mon.id * 9) + 1,
        default = true
    })
end
local function workspaces_set()
    for _, mon in pairs(hl.get_monitors()) do
        monitor_set(mon)
    end
end

-- Bindings

local function layout_bind(bind_table)
    return function()
        local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()

        if not workspace then
            return
        end

        local layout = workspace.tiled_layout

        if bind_table[layout] then
            hl.dispatch(bind_table[layout])
        end
    end
end

-- Focus
hl.bind(mod .. " + s", layout_bind({
    master = hl.dsp.layout("cyclenext"),
    scrolling = hl.dsp.layout("focus l")
}))
hl.bind(mod .. " + t", layout_bind({
    master = hl.dsp.layout("cycleprev"),
    scrolling = hl.dsp.layout("focus r")
}))
hl.bind(mod .. " + m", layout_bind({
    master = hl.dsp.layout("swapnext"),
    scrolling = hl.dsp.layout("focus u")
}))
hl.bind(mod .. " + n", layout_bind({
    master = hl.dsp.layout("swapprev"),
    scrolling = hl.dsp.layout("focus d")
}))

-- Move
-- TODO: What?
hl.bind(mod .. " + CTRL + s", layout_bind({
    master = hl.dsp.layout("rollprev"),
    scrolling = hl.dsp.layout("move -col")
}))
hl.bind(mod .. " + CTRL + t", layout_bind({
    master = hl.dsp.layout("rollnext"),
    scrolling = hl.dsp.layout("move +col")
}))
hl.bind(mod .. " + CTRL + m", layout_bind({
    master = hl.dsp.window.move({
        direction = "up"
    }),
    scrolling = hl.dsp.window.move({
        direction = "up"
    })
}))
hl.bind(mod .. " + CTRL + n", layout_bind({
    master = hl.dsp.window.move({
        direction = "down"
    }),
    scrolling = hl.dsp.window.move({
        direction = "down"
    })
}))
hl.bind(mod .. " + ALT + s", layout_bind({
    master = hl.dsp.window.move({
        direction = "left"
    }),
    scrolling = hl.dsp.window.move({
        direction = "left"
    })
}))
hl.bind(mod .. " + ALT + t", hl.dsp.window.move({
    direction = "right"
}))
hl.bind(mod .. " + ALT + m", hl.dsp.window.move({
    direction = "up"
}))
hl.bind(mod .. " + ALT + n", hl.dsp.window.move({
    direction = "down"
}))

-- Resize
hl.bind("CTRL + ALT + t", layout_bind({
    master = hl.dsp.layout("mfact +0.2"),
    scrolling = hl.dsp.layout("colresize +conf")
}))
hl.bind("CTRL + ALT + s", layout_bind({
    master = hl.dsp.layout("mfact -0.2"),
    scrolling = hl.dsp.layout("colresize -conf")
}))

-- Swap
hl.bind("SUPER + SHIFT + s", layout_bind({
    master = hl.dsp.layout("swapwithmaster"),
    scrolling = hl.dsp.layout("swapcol l")
}))
hl.bind("SUPER + SHIFT + t", layout_bind({
    master = hl.dsp.layout("swapwithmaster"),
    scrolling = hl.dsp.layout("swapcol r")
}))
hl.bind("SUPER + SHIFT + m", layout_bind({
    master = hl.dsp.window.swap({
        direction = "u"
    }),
    scrolling = hl.dsp.window.swap({
        direction = "u"
    })
}))
hl.bind("SUPER + SHIFT + n", layout_bind({
    master = hl.dsp.window.swap({
        direction = "d"
    }),
    scrolling = hl.dsp.window.swap({
        direction = "d"
    })
}))

-- Workspaces
-- Focus workspace 1-9, move window to workspace 1-9
for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({
        workspace = "r~" .. i,
        on_current_monitor = true
    }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({
        workspace = "r~" .. i
    }))
end

-- Special workspace
hl.bind(mod .. " + 0", hl.dsp.workspace.toggle_special())
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({
    workspace = "special"
}))

-- Relative workspace focus
hl.bind("SUPER + period", hl.dsp.focus({
    workspace = "r-1"
}))
hl.bind("SUPER + comma", hl.dsp.focus({
    workspace = "r+1"
}))
hl.bind("SUPER + mouse_down", hl.dsp.focus({
    workspace = "e+1"
}))
hl.bind("SUPER + mouse_up", hl.dsp.focus({
    workspace = "e-1"
}))

-- Monitor focus and window move
hl.bind(mod .. " + SHIFT + period", hl.dsp.focus({
    workspace = "m-1"
}))
hl.bind(mod .. " + SHIFT + comma", hl.dsp.focus({
    workspace = "m+1"
}))
hl.bind(mod .. " + CTRL + period", hl.dsp.focus({
    monitor = "l"
}))
hl.bind(mod .. " + CTRL + comma", hl.dsp.focus({
    monitor = "r"
}))
hl.bind(mod .. " + SHIFT + ALT + period", hl.dsp.window.move({
    monitor = "l"
}))
hl.bind(mod .. " + SHIFT + ALT + comma", hl.dsp.window.move({
    monitor = "r"
}))

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(TERMINAL))
hl.bind(mod .. " + ALT + Return", hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd(nix.pkgs.CopyQ .. " toggle"))
hl.bind(mod .. " + Q", hl.dsp.window.close())

-- Group
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + SHIFT + N", hl.dsp.group.next())
hl.bind(mod .. " + SHIFT + P", hl.dsp.group.prev())

hl.bind("SUPER_L + SHIFT_L + ALT_L + CTRL_L + C", hl.dsp.exec_cmd(nix.pkgs.yt))

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd(nix.pkgs.snapshot .. " area"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd(nix.pkgs.snapshot .. " active"))
hl.bind("ALT + Print", hl.dsp.exec_cmd(nix.pkgs.snapshot .. " output"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind("SUPER + L", hl.dsp.exec_cmd("walker"))
hl.bind(mod .. " + X", hl.dsp.exec_cmd("noctalia msg panel-toggle notification"))
hl.bind(mod .. " + escape", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind(mod .. " + SHIFT + escape", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
hl.bind(mod .. " + z", hl.dsp.workspace.toggle_special("term"))
hl.bind(mod .. " + j", hl.dsp.workspace.toggle_special("file"))

-- Audio and brightness
hl.bind("XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(nix.pkgpath.wireplumber .. "/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"), {
        locked = true,
        repeating = true
    })
hl.bind("XF86AudioLowerVolume",
    hl.dsp.exec_cmd(nix.pkgpath.wireplumber .. "/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"), {
        locked = true,
        repeating = true
    })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(nix.pkgs.brightnessctl .. " set +5%"), {
    locked = true,
    repeating = true
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(nix.pkgs.brightnessctl .. " set  5%-"), {
    locked = true,
    repeating = true
})

hl.bind("XF86AudioMute", hl.dsp.exec_cmd(nix.pkgpath.wireplumber .. "/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    {
        locked = true
    })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(nix.pkgs.playerctl .. " play-pause"), {
    locked = true
})
hl.bind("XF86AudioStop", hl.dsp.exec_cmd(nix.pkgs.playerctl .. " pause"), {
    locked = true
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(nix.pkgs.playerctl .. " pause"), {
    locked = true
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(nix.pkgs.playerctl .. " previous"), {
    locked = true
})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(nix.pkgs.playerctl .. " next"), {
    locked = true
})

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), {
    mouse = true
})
hl.bind("ALT + mouse:272", hl.dsp.window.resize(), {
    mouse = true
})

-- Environment variables
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "32")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("CHROMIUM_FLAGS", "\"--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4\"")
hl.env("XDG_DATA_DIRS", os.getenv("XDG_DATA_DIRS") .. ":" .. os.getenv("HOME") ..
    "/.nix-profile/share:/nix/var/nix/profiles/default/share")
hl.env("XCOMPOSEFILE", "~/.XCompose")
hl.env("EDITOR", "nvim")
hl.env("GTK_THEME", "Adwaita:dark")

-- Layer rules
hl.layer_rule({
    match = {
        namespace = "quickshell:bar"
    },
    blur = true
})

hl.layer_rule({
    match = {
        namespace = "quickshell:popout"
    },
    blur = true
})

hl.layer_rule({
    match = {
        namespace = "quickshell:modal"
    },
    blur = true
})

hl.layer_rule({
    match = {
        namespace = "quickshell:notification"
    },
    no_screen_share = true
})

hl.layer_rule({
    match = {
        namespace = "selection"
    },
    no_anim = true,
    blur = false
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "3840x2160@60",
    position = "2560x0",
    scale = "1.5"
})

hl.monitor({
    output = "DP-3",
    mode = "2560x1440@165",
    position = "0x0",
    scale = "1"
})

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1"
})

hl.window_rule({
    match = {
        class = "^(com.github.hluk.copyq)$"
    },
    float = true,
    stay_focused = true,
    center = true,
    size = "1800 1000"
})

hl.window_rule({
    match = {
        class = "^(system-monitoring-center)$"
    },
    float = true,
    center = true,
    size = "1800 1000"
})

hl.window_rule({
    match = {
        class = "([Tt]hunar)",
        title = "(File Operation Progress)"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "([Tt]hunar)",
        title = "(Confirm to replace files)"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "xdg-desktop-portal-gtk",
        title = "File Upload"
    },
    size = "{800, 600}",
    float = true,
    center = true
})

hl.window_rule({
    match = {
        class = "(codium|codium-url-handler|VSCodium|code-oss)",
        title = "(Add Folder to Workspace)"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "(electron)",
        title = "(Add Folder to Workspace)"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "^(nm-applet|nm-connection-editor|blueman-manager)$"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$"
    },
    float = true
})

hl.window_rule({
    match = {
        title = "(Kvantum Manager)"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "^([Qq]alculate-gtk)$"
    },
    float = true
})

hl.window_rule({
    match = {
        title = "^(Picture-in-Picture)$"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "^(.*jetbrains.*)$",
        title = "^(win[0-9]+)$"
    },
    no_initial_focus = true
})

hl.window_rule({
    match = {
        title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
    },
    tag = "+picture-in-picture"
})

hl.window_rule({
    match = {
        tag = "picture-in-picture"
    },
    float = true,
    keep_aspect_ratio = true,
    move = "73% 72%",
    size = "25% 25%",
    pin = true
})

hl.window_rule({
    match = {
        class = "^(Brave-browser(-beta|-dev)?)$"
    },
    opacity = "0.9 0.9"
})

hl.window_rule({
    match = {
        class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
    },
    opacity = "1 override 0.9 override"
})

hl.window_rule({
    match = {
        class = "^(google-chrome(-beta|-dev|-unstable)?)$"
    },
    opacity = "0.9 0.9"
})

hl.window_rule({
    match = {
        class = "^(chrome-.+-Default)$"
    },
    opacity = "0.94 0.86"
})

hl.window_rule({
    match = {
        class = "^([Tt]hunar|org.gnome.Nautilus)$"
    },
    opacity = "0.9 0.8"
})

hl.window_rule({
    match = {
        class = "^(deluge)$"
    },
    opacity = "0.9 0.8"
})

hl.window_rule({
    match = {
        class = "^(org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$"
    },
    opacity = "0.8 0.7"
})

hl.window_rule({
    match = {
        class = "^(VSCodium|codium-url-handler|code-oss)$"
    },
    opacity = "0.8 0.8"
})

hl.window_rule({
    match = {
        class = "^([Cc]ode)$"
    },
    opacity = "0.8 0.8"
})

hl.window_rule({
    match = {
        class = "^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
    },
    opacity = "0.9 0.8"
})

hl.window_rule({
    match = {
        class = "^(kvantummanager)"
    },
    opacity = "0.8 0.8"
})

hl.window_rule({
    match = {
        class = "^(com.obsproject.Studio)$"
    },
    opacity = "0.9 0.7"
})

hl.window_rule({
    match = {
        class = "^([Aa]udacious)$"
    },
    opacity = "0.9 0.7"
})

hl.window_rule({
    match = {
        class = "^(VSCode|code-url-handler)$"
    },
    opacity = "1 1"
})

hl.window_rule({
    match = {
        class = "^(jetbrains-.+)$"
    },
    opacity = "1 1"
})

hl.window_rule({
    match = {
        class = "^([Dd]iscord|[Vv]esktop)$"
    },
    opacity = "0.94 0.86"
})

hl.window_rule({
    match = {
        class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
    },
    opacity = "0.9 0.8"
})

hl.window_rule({
    match = {
        class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$"
    },
    opacity = "0.82 0.75"
})

hl.window_rule({
    match = {
        class = "^(xdg-desktop-portal-gtk)$"
    },
    opacity = "0.9 0.8"
})

hl.window_rule({
    match = {
        title = "^(Picture-in-Picture)$"
    },
    opacity = "0.95 0.75"
})

hl.workspace_rule({
    workspace = "special:term",
    on_created_empty = "wezterm-gui"
})

hl.workspace_rule({
    workspace = "special:file",
    on_created_empty = "dolphin"
})

hl.workspace_rule({
    workspace = "m[HDMI-A-1]",
    layout = "scrolling"
})

hl.workspace_rule({
    workspace = "m[DP-3]",
    layout = "master"
})

-- Smart gaps
hl.workspace_rule({
    workspace = "w[tv1]s[false]",
    gaps_out = 0,
    gaps_in = 0
})
hl.workspace_rule({
    workspace = "f[1]s[false]",
    gaps_out = 0,
    gaps_in = 0
})
hl.window_rule({
    match = {
        float = false,
        workspace = "w[tv1]s[false]"
    },
    border_size = 0
})
hl.window_rule({
    match = {
        float = false,
        workspace = "w[tv1]s[false]"
    },
    rounding = 0
})
hl.window_rule({
    match = {
        float = false,
        workspace = "f[1]s[false]"
    },
    border_size = 0
})
hl.window_rule({
    match = {
        float = false,
        workspace = "f[1]s[false]"
    },
    rounding = 0
})

hl.config({
    decoration = {
        rounding = 20,
        dim_inactive = false,
        active_opacity = 0.98,
        blur = {
            enabled = true,
            size = 3,
            passes = 3,
            ignore_opacity = true,
            new_optimizations = true,
            xray = false,
            brightness = 1,
            noise = 0.01,
            contrast = 1,
            popups = true,
            popups_ignorealpha = 0.6
        },
        shadow = {
            offset = "0, 0",
            range = 30,
            render_power = 1,
            color = "0x000000"
        }
    },
    ecosystem = {
        no_update_news = true
    },
    general = {
        gaps_in = 3,
        gaps_out = 30,
        border_size = 3,
        resize_on_border = true,
        col = {
            active_border = {
                colors = {nix.vars.lavender, nix.vars.mauve, nix.vars.red},
                angle = 45
            },
            inactive_border = "rgba(00000000)"
        }
    },
    group = {
        groupbar = {
            col = {
                active = "rgb(7fbbb3)",
                inactive = "rgb(859289)"
            },
            font_size = 10,
            text_color = nix.vars.textcolor
        },
        col = {
            border_active = {
                colors = {nix.vars.mauve, nix.vars.red, nix.vars.blue},
                angle = 45
            },
            border_inactive = {
                colors = {nix.vars.green, nix.vars.mauve},
                angle = 45
            },
            border_locked_active = {
                colors = {nix.vars.mauve, nix.vars.blue},
                angle = 45
            },
            border_locked_inactive = {
                colors = {nix.vars.green, nix.vars.mauve},
                angle = 45
            }
        }
    },
    misc = {
        background_color = "rgb(272e33)",
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        vrr = 2
    },
    xwayland = {
        force_zero_scaling = true
    },
    debug = {
        disable_logs = false
    },
    scrolling = {
        column_width = 0.8,
        focus_fit_method = 0
    }
})

hl.on("hyprland.start", function()
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd --all && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd(nix.pkgs.awww)
    hl.exec_cmd(nix.pkgpath.kwallet .. "/libexec/pam_kwallet_init")
    hl.exec_cmd(nix.pkgs.CopyQ .. " --start-server")
    hl.exec_cmd("bash -c \"wl-paste --watch cliphist store &\"")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("phone-deck --port 4567")
    workspaces_set()
end)
hl.on("monitor.added", monitor_set)

hl.on("config.reloaded", function()
    hl.exec_cmd("hass-report-status http://homeassistant.local/api/webhook/eaea48a1-30e3-47bf-a076-30f816f0d3d1 true")
    workspaces_set()
end)

