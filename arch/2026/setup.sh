#!/bin/bash

# Stop ved fejl
set -e

echo "🚀 Starter installation af din Arch-maskine (med Keychain)..."

PREFERRED_LOCALE=en_DK.UTF-8
sudo perl -pibak  -e 's/^#en_DK.UTF-8/en_DK.UTF-8/g' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=${PREFERRED_LOCALE}

sudo localectl set-x11-keymap dk

# 1. Installer officielle pakker
echo "📦 Installerer systempakker..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm openssh base-devel git docker tailscale fzf trash-cli keychain openssh autorandr rsync thunderbird
# arch-install-scripts python-psutil
sudo pacman -S --needed --noconfirm yazi ffmpeg 7zip jq poppler zoxide resvg imagemagick inotify-tools pass gpg
sudo pacman -S --needed --noconfirm mplayer smplayer fwupd less 7zip gnupg pass bash-completion thunar terminator wezterm zstd unrar

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

. $HOME/.local/bin/env

# 2. Installer yay (AUR helper) hvis den mangler
if ! command -v yay &> /dev/null; then
    echo "🏗️  Bygger yay..."
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd -
fi

# 3. Installer AUR pakker (-bin)
echo "💎 Installerer AUR pakker..."
yay -S --noconfirm vscodium-bin google-chrome starship-bin quarto-cli-bin  qemu-full quickemu cpupower power-profiles-daemon
yay -S --noconfirm solaar impala lazaygit lazydocker git-credential-manager-bin gvfs thunar-volman udisks2 # llama.cpp-vulkan
yay -S --noconfirm thermald asusctl

# 4. Start services
echo "🔌 Starter Docker, Incus og Tailscale..."
sudo systemctl enable --now docker
#sudo systemctl enable --now incusd
sudo systemctl enable --now tailscaled
sudo usermod -aG docker $USER

# 5. SSH Setup
echo "🔑 Konfigurerer SSH..."
mkdir -p ~/.ssh && chmod 700 ~/.ssh
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Genererer ny Ed25519 nøgle..."
    # Her genereres nøglen. Du bliver bedt om en passphrase manuelt.
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
fi
sudo systemctl start sshd && sudo systemctl enable sshd

# amd pstate
sudo tee /etc/udev/rules.d/99-cpu-permissions.rules <<EOF
# Robust rettighedsstyring til Ryzen AI 365
ACTION=="add|change", SUBSYSTEM=="cpu", RUN+="/bin/sh -c 'chown $(whoami) /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference'"
ACTION=="add|change", SUBSYSTEM=="cpufreq", RUN+="/bin/sh -c 'chown $(whoami) /sys/devices/system/cpu/cpufreq/boost'"
EOF

sudo udevadm control --reload-rules && sudo udevadm trigger

# [heas@ai365 yay-bin]$ echo "power" > /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
# [heas@ai365 yay-bin]$ echo "balance_power" > /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
# [heas@ai365 yay-bin]$ echo "balance_performance" > /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
# [heas@ai365 yay-bin]$ echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference

# 6. Mise (Runtimes)
echo "🛠️  Installerer Mise & Runtimes..."
if [ ! -f ~/.local/bin/mise ]; then
    curl https://mise.jdx.dev/install.sh | sh
fi
~/.local/bin/mise install node@20.11 go@1.22 bun@latest -y

# 7. Cargo-binstall & Rust tools
echo "🦀 Installerer Rust værktøjer..."
curl -L https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
~/.cargo/bin/cargo-binstall -y ripgrep fd-find starship

tee -a ~/.bashrc <<'EOF'
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
EOF

tee -a ~/.bashrc <<EOF

# Ryzen AI 365 Power Profiles
alias p-power='for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo "power" > "\$f"; done && echo "Profile: power (Silent)"'
alias p-bal='for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo "balance_power" > "\$f"; done && echo "Profile: balance_power (Efficient)"'
alias p-perf='for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo "balance_performance" > "\$f"; done && echo "Profile: balance_performance (Fast)"'
EOF

# 8. Konfigurationsfiler
echo "📝 Opsætter konfigurationer..."
mkdir -p ~/.config/yazi ~/.config/Code/User

I3_CONFIG_DIR=~/.config/i3
I3_CONFIG=${I3_CONFIG_DIR}/config
tee -a ${I3_CONFIG} <<-EOF
include ~/.config/i3/config.d/*.conf
EOF
perl -pi.bak -e 's/^bindsym..mod.Return/#bindsym $mod+Return/g' $I3_CONFIG

mkdir ${I3_CONFIG_DIR}/config.d
tee -a ${I3_CONFIG_DIR}/config.d/i3-include-config <<'EOF'
bindsym $mod+Return exec wezterm #terminator #i3-sensible-terminal

bindsym $mod+t exec --no-startup-id antigravity
bindsym $mod+g exec --no-startup-id google-chrome-stable
bindsym $mod+m exec --no-startup-id thunderbird
bindsym $mod+u exec --no-startup-id thunar
bindsym $mod+i exec --no-startup-id idle
bindsym $mod+n exec terminator -e ranger
bindsym $mod+c exec --no-startup-id code
bindsym $mod+p exec --no-startup-id keepass2
bindsym $mod+y exec --no-startup-id smplayer

bindsym $mod+F10 exec pactl set-sink-mute @DEFAULT_SINK@ toggle # Mute
bindsym $mod+F11 exec pactl set-sink-volume @DEFAULT_SINK@ -5%  # Up
bindsym $mod+F12 exec pactl set-sink-volume @DEFAULT_SINK@ +5%  # Down

bar {
    output            LVDS1
    status_command    i3status
    position          top
    mode              hide
    workspace_buttons yes
    tray_output       none

    font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1

    colors {
        background #000000
        statusline #ffffff

        focused_workspace  #ffffff #285577
        active_workspace   #ffffff #333333
        inactive_workspace #888888 #222222
        urgent_workspace   #ffffff #900000
    }
}
EOF

# Yazi Keymap
cat <<EOF > ~/.config/yazi/keymap.toml
[manager]
prepend_keymap = [
    { on = [ "l" ], exec = "plugin --sync smart-enter", desc = "Enter or Open" },
    { on = [ "g", "c" ], exec = "cd ~/.config", desc = "Go to Config" },
    { on = [ "C" ], exec = "shell 'codium .'", desc = "Open in VSCodium" },
    { on = [ "d" ], exec = "shell 'trash-put \"\$@\"' --confirm", desc = "Trash" }
]
EOF

tee -a ~/.config/yazi/yazi.toml <<-EOF
[mgr]
show_hidden = true
ratio = [1, 2, 7]

[preview]
max_width = 3840
max_height = 2160
image_quality = 90
wrap = "yes"

[plugin]

prepend_preloaders = [
    # Office Documents
    { mime = "application/openxmlformats-officedocument.*", run = "office" },
    { mime = "application/oasis.opendocument.*", run = "office" },
    { mime = "application/ms-*", run = "office" },
    { mime = "application/msword", run = "office" },
    { name = "*.docx", run = "office" },
]

prepend_previewers = [
    # Office Documents
    { mime = "application/openxmlformats-officedocument.*", run = "office" },
    { mime = "application/oasis.opendocument.*", run = "office" },
    { mime = "application/ms-*", run = "office" },
    { mime = "application/msword", run = "office" },
    { name = "*.docx", run = "office" },
]
EOF

# Starship Config
cat <<EOF > ~/.config/starship.toml
add_newline = true
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"
EOF

CONF_FILE=/etc/ssh/sshd_config.d/hardened.conf

sudo tee $CONF_FILE <<EOF
# SSH Hardening & X11 Forwarding
PermitRootLogin no
PubkeyAuthentication yes
AuthenticationMethods publickey
ChallengeResponseAuthentication no
PasswordAuthentication no

# X11 & TCP Forwarding
X11Forwarding yes
AllowTcpForwarding yes
X11UseLocalhost yes
X11DisplayOffset 10
EOF

sudo systemctl restart sshd


# 9. Bashrc integration (Her opsættes Keychain)
echo "🐚 Opdaterer .bashrc..."
# Tilføj Mise og Starship
grep -qq "mise activate" ~/.bashrc || echo 'eval "$($HOME/.local/bin/mise activate bash)"' >> ~/.bashrc
grep -qq "starship init" ~/.bashrc || echo 'eval "$(starship init bash)"' >> ~/.bashrc
grep -qq "fzf" ~/.bashrc || echo 'source /usr/share/fzf/completion.bash && source /usr/share/fzf/key-bindings.bash' >> ~/.bashrc

# Keychain integration: Starter agenten og loader din id_ed25519 nøgle
if ! grep -qq "keychain" ~/.bashrc; then
    echo 'eval $(keychain --eval --agents ssh id_ed25519)' >> ~/.bashrc
fi

echo "🎉 Færdig! Log ud og ind igen."

tee ~/.gitconfig <<EOF
[user]
name = heas
email = henrik@haskoe.dk
[pull]
rebase = false
[credential]
credentialStore = gpg
helper = /usr/bin/git-credential-manager

[credential "https://dev.azure.com"]
useHttpPath = true

[includeIf "gitdir:~/proj/lgo0101/"]
path = ~/.gitconfig-lgo0101

[includeIf "gitdir:~/proj/heas0404/"]
path = ~/.gitconfig-heas0404
EOF

tee ~/.gitconfig-lgo0101 <<EOF
[user]
name = heas
email = heas@gott-it.dk
EOF

tee ~/.gitconfig-heas0404 <<EOF
[user]
name = heas
email = heas@gott-it.dk
EOF

# opencode
curl -fsSL https://opencode.ai/install | bash
source ~/.bashrc
OPENCODE_CONFIG_DIR=~/.config/opencode
[[ ! -d $OPENCODE_CONFIG_DIR ]] && mkdir -p $OPENCODE_CONFIG_DIR
tee ${OPENCODE_CONFIG_DIR}/opencode.json.new <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "llama.cpp": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "llama-server (local)",
      "options": {
        "baseURL": "http://s990:8080/v1"
      },
      "models": {
        "glm-4.6v-flash": {
          "name": "GLM-4.6V-Flash (local)",
          "modalities": { "input": ["image", "text"], "output": ["text"] },
          "limit": {
            "context": 32000,
            "output": 65536
          }
        }
      }
    }
  }
}
EOF
OPENCODE_SHARE_DIR=~/.local/share/opencode
[[ ! -d $OPENCODE_SHARE_DIR ]] && mkdir -p $OPENCODE_SHARE_DIR
tee ${OPENCODE_CONFIG_DIR}/auth.json.new <<EOF
{
  "openrouter": {
    "type": "api",
    "key": "you key here"
  }
}
EOF

# Mode til manuel styring af Ryzen AI 365 Power Profiles
set $mode_power "Power: [p]erf, [b]alanced, [s]aver, [e]nergy (silent)"

mode "$mode_power" {
    # Performance - Maksimal fart
    bindsym p exec --no-startup-id sh -c 'echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference', mode "default"

    # Balanced - Standard (balance_performance)
    bindsym b exec --no-startup-id sh -c 'echo "balance_performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference', mode "default"

    # Saver - Den gyldne middelvej (balance_power)
    bindsym s exec --no-startup-id sh -c 'echo "balance_power" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference', mode "default"

    # Energy - Total stilhed (power)
    bindsym e exec --no-startup-id sh -c 'echo "power" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference', mode "default"

    # Exit mode
    bindsym Return mode "default"
    bindsym Escape mode "default"
}

# Bind mode til en tast (f.eks. Mod4 + Shift + p)
bindsym $mod+Shift+p mode "$mode_power"
