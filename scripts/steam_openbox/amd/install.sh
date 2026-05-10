#!/bin/bash
echo "Initializing minimal Steam (AMD) Archlinux install..."
set -e

USERNAME="$USER"
USERID="$UID"

################################## Creating User
sudo usermod -aG video,input,render,wheel $USER
##################################

################################## Multilib
echo "Enable Multilib..."
FILE="/etc/pacman.conf"

if grep -q "^\s*\[multilib\]" "$FILE"; then
  sudo sed -i '/^\s*#\?\s*\[multilib\]/,/^\s*#\?\s*Include/ s/^\s*#\s*//' "$FILE"
else
  printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' | sudo tee -a "$FILE" > /dev/null
fi

sudo pacman -Syu --noconfirm
##################################

################################## Update
echo "System Updating..."
sudo pacman -Sc --noconfirm
sudo pacman-key --populate archlinux
sudo pacman -Sy --noconfirm archlinux-keyring
sudo pacman -Syu --noconfirm
sudo pacman -Sy --needed --noconfirm iwd
sudo pacman -S --needed --noconfirm sdl2-compat gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg samba gnutls lib32-alsa-oss
sudo pacman -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa lib32-pipewire lib32-libpulse lib32-alsa-lib lib32-alsa-plugins
sudo pacman -S --needed --noconfirm --needed gcc-libs lib32-gcc-libs glibc lib32-glibc
sudo pacman -S --needed --noconfirm \
  webkit2gtk-4.1 \
  base-devel \
  curl \
  wget \
  file \
  openssl \
  appmenu-gtk-module \
  libappindicator-gtk3 \
  librsvg \
  xdotool

sudo pacman -S --needed --noconfirm xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon mesa mesa-utils vulkan-tools lib32-mesa libva-mesa-driver
sudo pacman -S --needed --noconfirm xorg-server xorg-xinit xorg-xrandr steam xterm unclutter openbox
##################################

################################## Tools
echo "Installing Tools..."
sudo pacman -S --needed --noconfirm fastfetch
sudo pacman -S --needed --noconfirm kitty
sudo pacman -S --needed --noconfirm ninja
sudo pacman -S --needed --noconfirm clang
sudo pacman -S --needed --noconfirm gcc
sudo pacman -S --needed --noconfirm git
sudo pacman -S --needed --noconfirm make
sudo pacman -S --needed --noconfirm ncurses
sudo pacman -S --needed --noconfirm flex
sudo pacman -S --needed --noconfirm less
sudo pacman -S --needed --noconfirm bison
sudo pacman -S --needed --noconfirm gperf
sudo pacman -S --needed --noconfirm eza
sudo pacman -S --needed --noconfirm fzf
sudo pacman -S --needed --noconfirm wireshark-cli
sudo pacman -S --needed --noconfirm zip
sudo pacman -S --needed --noconfirm unzip
sudo pacman -S --needed --noconfirm btop
sudo pacman -S --needed --noconfirm iotop
sudo pacman -S --needed --noconfirm brightnessctl
sudo pacman -S --needed --noconfirm ffmpeg
sudo pacman -S --needed --noconfirm openrgb
sudo pacman -S --needed --noconfirm pacman-contrib
##################################

################################## Yay
if ! command -v yay >/dev/null 2>&1; then
  echo "Installing yay..."
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin || exit
  makepkg -si
else
  echo "yay already installed, skipping"
fi

cd ../
##################################

################################## Essential networking
echo "Configuring Networks..."
sudo pacman -S --needed --noconfirm iwd

sudo mkdir -p /etc/iwd
sudo mkdir -p /etc/systemd/resolved.conf.d

sudo tee /etc/iwd/main.conf >/dev/null <<'EOF'
[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd
EOF

sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf >/dev/null <<'EOF'
[Resolve]
DNS=8.8.8.8 1.1.1.1 1.0.0.1
Domains=~.
EOF

sudo systemctl enable iwd.service
sudo systemctl enable systemd-resolved.service
##################################

################################## APPS
echo "Installing Apps..."
yay -S --needed --noconfirm brave-bin
yay -S --needed --noconfirm cava
yay -S --needed --noconfirm yazi
yay -S --needed --noconfirm rar
yay -S --needed --noconfirm pipes.sh
yay -S --needed --noconfirm tty-clock
yay -S --needed --noconfirm unimatrix
##################################

################################## Settings
echo "Configuring System Settings..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
##################################

################################## Startx
grep -qxF 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then' ~/.bash_profile 2>/dev/null || cat >> ~/.bash_profile <<'EOF'

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx
fi
EOF

cat > ~/.xinitrc <<'EOF'
#!/bin/sh
exec openbox-session
EOF

chmod +x ~/.xinitrc

sudo mkdir -p ~/.config/openbox
cat > ~/.config/openbox/autostart <<'EOF'
#!/bin/sh
xset -dpms
xset s off
xset s noblank

steam -gamepadui
EOF

##################################

################################## Autologin
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d

sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF

sudo systemctl daemon-reload
sudo systemctl restart getty@tty1
##################################

##################################
echo ""
echo "✅ Done. Configured for user: [$USERNAME]"
##################################
