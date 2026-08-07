-- ============================================================================
-- WezTerm configuration -- cross-platform (macOS + Linux)
-- ============================================================================

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- ----------------------------------------------------------------------------
-- Platform detection
-- ----------------------------------------------------------------------------
local TARGET     = wezterm.target_triple
local IS_MAC     = TARGET:find("apple%-darwin") ~= nil
local IS_LINUX   = TARGET:find("linux") ~= nil
local IS_WINDOWS = TARGET:find("windows") ~= nil
local HOME       = os.getenv("HOME") or ""

-- ----------------------------------------------------------------------------
-- Helpers
-- ----------------------------------------------------------------------------

-- WezTerm's GUI process on macOS only inherits a minimal PATH
-- (/usr/bin:/bin:/usr/sbin:/sbin), so bare binary names like "nu" fail to
-- spawn. We resolve absolute paths ourselves instead of trusting PATH.
local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Return the first path in the list that exists on disk, else `fallback`.
local function resolve(candidates, fallback)
    for _, path in ipairs(candidates) do
        if file_exists(path) then
            return path
        end
    end
    return fallback
end

-- Pick a value based on platform.
local function per_os(opts)
    if IS_MAC then return opts.mac end
    if IS_LINUX then return opts.linux end
    if IS_WINDOWS then return opts.windows end
    return opts.default
end

-- ----------------------------------------------------------------------------
-- Constants: binary search paths
-- ----------------------------------------------------------------------------
local BIN_CANDIDATES = {
    nu = per_os({
        mac = {
            "/opt/homebrew/bin/nu",       -- Homebrew, Apple Silicon
            "/usr/local/bin/nu",          -- Homebrew, Intel
            HOME .. "/.cargo/bin/nu",     -- cargo install nu
        },
        linux = {
            "/usr/bin/nu",
            "/usr/local/bin/nu",
            "/home/linuxbrew/.linuxbrew/bin/nu",
            HOME .. "/.cargo/bin/nu",
        },
    }),

    bash = per_os({
        mac = {
            "/opt/homebrew/bin/bash",     -- modern bash from Homebrew
            "/usr/local/bin/bash",
            "/bin/bash",                  -- system bash 3.2, always present
        },
        linux = {
            "/usr/bin/bash",
            "/bin/bash",
        },
    }),
}

-- Resolved once at startup. Falls back to the bare name so the config still
-- loads (and gives a clear WezTerm error) if the binary genuinely isn't there.
local BIN = {
    nu   = resolve(BIN_CANDIDATES.nu, "nu"),
    bash = resolve(BIN_CANDIDATES.bash, "bash"),
}

local SHELLS = {
    nu   = { BIN.nu, "-l" },
    bash = { BIN.bash, "-l" },
}

-- ----------------------------------------------------------------------------
-- Constants: appearance
-- ----------------------------------------------------------------------------
local FONTS = {
    primary = "JetBrainsMono Nerd Font",
    secondary = "FiraCode Nerd Font",
    emoji = per_os({
        mac   = "Apple Color Emoji",
        linux = "Noto Color Emoji",
    }),
}

local APPEARANCE = {
    color_scheme       = "Noctalia",
    font_size          = per_os({ mac = 15, linux = 12 }),
    window_opacity     = 0.95,
    text_opacity       = 0.8,
    -- macOS: "NONE" also strips the traffic-light buttons, so use RESIZE.
    -- Linux: "NONE" is usually what you want under a tiling WM.
    window_decorations = per_os({ mac = "RESIZE", linux = "NONE" }),
    initial_cols       = 120,
    initial_rows       = 28,
    max_fps            = 120,
    scrollback_lines   = 10000,
}

-- ============================================================================
-- Configuration
-- ============================================================================

config.default_prog = SHELLS.nu

config.launch_menu = {
    { label = "Nushell (login)", args = SHELLS.nu },
    { label = "Bash (login)",    args = SHELLS.bash },
}

-- Fonts
config.font = wezterm.font_with_fallback({
    FONTS.primary,
    FONTS.secondary,
    FONTS.emoji,
})
config.font_size = APPEARANCE.font_size

-- Window / geometry
config.initial_cols = APPEARANCE.initial_cols
config.initial_rows = APPEARANCE.initial_rows
config.use_fancy_tab_bar = true
config.window_decorations = APPEARANCE.window_decorations
config.window_close_confirmation = "NeverPrompt"

-- Colors & transparency
config.color_scheme = APPEARANCE.color_scheme
config.window_background_opacity = APPEARANCE.window_opacity
config.text_background_opacity = APPEARANCE.text_opacity

-- Performance & behaviour
config.max_fps = APPEARANCE.max_fps
config.scrollback_lines = APPEARANCE.scrollback_lines
config.audible_bell = "Disabled"

-- Fixes nvim not detecting <C-S-Left/Right>
config.enable_csi_u_key_encoding = true

-- ----------------------------------------------------------------------------
-- Platform-specific tweaks
-- ----------------------------------------------------------------------------
if IS_LINUX then
    -- eGPU / Wayland workarounds. Setting enable_wayland = false has been
    -- observed to make things worse (opaque editor), so both stay off by
    -- default -- uncomment only if you hit rendering issues.
    -- config.enable_wayland = false
    -- config.prefer_egl = false
end

if IS_MAC then
    -- Give child processes a PATH that includes Homebrew, since the GUI app
    -- doesn't inherit a login shell's PATH.
    config.set_environment_variables = {
        PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:"
            .. (os.getenv("PATH") or ""),
    }
end

-- ----------------------------------------------------------------------------
-- Keybindings
-- ----------------------------------------------------------------------------
config.keys = {
    -- Copy/Paste (no Shift circus)
    { key = "C",          mods = "CTRL",       action = act.CopyTo("Clipboard") },
    { key = "V",          mods = "CTRL",       action = act.PasteFrom("Clipboard") },

    -- Fullscreen
    { key = "F11",        mods = "NONE",       action = act.ToggleFullScreen },

    -- Splits
    { key = "D",          mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "D",          mods = "CTRL|ALT",   action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Tabs
    { key = "T",          mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "N",          mods = "CTRL|SHIFT", action = act.SpawnWindow },

    -- Tab switching with Ctrl+Arrow
    { key = "RightArrow", mods = "CTRL",       action = act.ActivateTabRelative(1) },
    { key = "LeftArrow",  mods = "CTRL",       action = act.ActivateTabRelative(-1) },

    -- Quick spawns
    { key = "U",          mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({ args = SHELLS.nu }) },
    { key = "B",          mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({ args = SHELLS.bash }) },

    -- Launcher for when you forget the shortcuts
    { key = "L",          mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS" }) },

    -- vim specific: let nvim receive these instead of WezTerm eating them
    { key = "RightArrow", mods = "SHIFT|CTRL", action = act.DisableDefaultAssignment },
    { key = "LeftArrow",  mods = "SHIFT|CTRL", action = act.DisableDefaultAssignment },

    -- Scrolling
    { key = "UpArrow",    mods = "CTRL|SHIFT", action = act.ScrollByLine(-1) },
    { key = "DownArrow",  mods = "CTRL|SHIFT", action = act.ScrollByLine(1) },
}

-- macOS muscle memory: Cmd+C / Cmd+V alongside the Ctrl bindings above.
-- if IS_MAC then
--     local mac_keys = {
--         { key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
--         { key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
--         { key = "n", mods = "CMD", action = act.SpawnWindow },
--         { key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
--     }
--     for _, k in ipairs(mac_keys) do
--         table.insert(config.keys, k)
--     end
-- end
--
-- ----------------------------------------------------------------------------
-- Mouse
-- ----------------------------------------------------------------------------
config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = "NONE",
        action = act.ScrollByLine(-5),
    },
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = "NONE",
        action = act.ScrollByLine(5),
    },
}

return config
