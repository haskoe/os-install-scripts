#!/bin/bash

# Stop ved fejl
set -e

echo "🚀 Starter installation af din Arch-maskine (med Keychain)..."

# 1. Installer officielle pakker
echo "📦 Installerer systempakker..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm openssh base-devel git docker tailscale fzf trash-cli keychain openssh
# arch-install-scripts python-psutil
sudo pacman -S --needed --noconfirm yazi ffmpeg 7zip jq poppler zoxide resvg imagemagick

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Installer yay (AUR helper) hvis den mangler
if ! command -v yay &> /dev/null; then
    echo "🏗️  Bygger yay..."
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd -
fi

# 3. Installer AUR pakker (-bin)
echo "💎 Installerer AUR pakker..."
yay -S --noconfirm vscodium-bin google-chrome starship-bin
yay -S --noconfirm solaar impala lazaygit lazydocker

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

# Definer stien til cargo bin
CARGO_BIN="$HOME/.cargo/bin"

# Tjek om stien allerede er i .bashrc, hvis ikke, tilføj den
if ! grep -q "$CARGO_BIN" "$HOME/.bashrc"; then
  echo "Tilføjer $CARGO_BIN til PATH i .bashrc"
  echo "export PATH=\"\$PATH:$CARGO_BIN\"" >> "$HOME/.bashrc"
else
  echo "Cargo bin findes allerede i PATH."
fi

# Opdater den nuværende session
export PATH="$PATH:$CARGO_BIN"

# 8. Konfigurationsfiler
echo "📝 Opsætter konfigurationer..."
mkdir -p ~/.config/yazi ~/.config/Code/User

I3_CONFIG_DIR=~/.config/i3
I3_CONFIG=${I3_CONFIG_DIR}/config
tee -a ${I3_CONFIG} <<-EOF
include ~/.config/i3/config.d/*.conf
EOF
perl -pi.bak -e 's/^bindsym..mod.Return/#bindsym $mod+Return/g' $I3_CONFIG 

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
mkdir ${I3_CONFIG_DIR}/config.d
[[ -f ${SCRIPT_DIR}/i3-config-include.conf ]] && cp ${SCRIPT_DIR}/i3-config-include.conf  ${I3_CONFIG_DIR}/config.d


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
