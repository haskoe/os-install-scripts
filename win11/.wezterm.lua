local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Grundlæggende indstillinger
config.color_scheme = 'Catppuccin Macchiato'
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 11.0

-- 1. Launch Menu (Højreklik på + knappen eller brug genvej til menu)
config.launch_menu = {
  {
    label = 'Ubuntu (WSL)',
    args = { 'wsl.exe', '-d', 'Ubuntu' },
  },
  {
    label = 'Debian (WSL)',
    args = { 'wsl.exe', '-d', 'Debian' },
  },
  {
    label = 'PowerShell Core',
    args = { 'pwsh.exe' },
  },
  {
    label = 'SSH til s990',
    args = { 'ssh', 'heas@s990' },
  },
}

-- 2. Genveje (Her lægges selve CTRL+SHIFT+L)
config.keys = {
  {
    key = 'L',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SpawnCommandInNewTab {
      args = { 'ssh', 'heas@s990' },
    },
  },
-- NY: Genvej til at åbne selve menuen (f.eks. med CTRL+SHIFT+SPACE)
  {
    key = 'm',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ShowLauncher,
  },
}

return config