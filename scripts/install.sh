#!/bin/bash

# YAY
git clone https://aur.archlinux.org/yay-bin.git
cd ./yay-bin
sudo makepkg -si

# Drivers
sudo pacman -S --needed --noconfirm mesa
sudo pacman -S --needed --noconfirm xf86-video-amdgpu
sudo pacman -S --needed --noconfirm vulkan-radeon
sudo pacman -S --needed --noconfirm libva-mesa-driver
# Update
sudo pacman -Sc --noconfirm
sudo pacman-key --populate archlinux
sudo pacman -Sy --noconfirm archlinux-keyring
sudo pacman -Syu --noconfirm
sudo pacman -Sy --needed --noconfirm iwd
sudo pacman -S --needed --noconfirm wine winetricks sdl2-compat gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg samba gnutls lib32-alsa-oss
sudo pacman -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa lib32-pipewire lib32-pipewire-pulse lib32-libpulse lib32-alsa-lib lib32-alsa-plugins
sudo pacman -S --needed --noconfirm vulkan-radeon lib32-vulkan-radeon mesa lib32-mesa
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

# Essential networking
sudo pacman -S --needed --noconfirm iwd

sudo mkdir /etc/iwd
sudo mkdir /etc/systemd/resolved.conf.d

sudo cat <<EOF | sudo tee /etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd
EOF

sudo cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=8.8.8.8 1.1.1.1 1.0.0.1
Domains=~.
EOF

sudo systemctl enable iwd.service
sudo systemctl enable systemd-resolved.service

# Hyprland base
sudo pacman -S --needed --noconfirm hyprland
sudo pacman -S --needed --noconfirm rofi-wayland
sudo pacman -S --needed --noconfirm hyprpaper
sudo pacman -S --needed --noconfirm hyprlock
sudo pacman -S --needed --noconfirm xdg-desktop-portal-hyprland
sudo pacman -S --needed --noconfirm xorg-xwayland

# Tools
sudo pacman -S --needed --noconfirm nmap
sudo pacman -S --needed --noconfirm kitty
sudo pacman -S --needed --noconfirm fastfetch
sudo pacman -S --needed --noconfirm base-devel
sudo pacman -S --needed --noconfirm ninja
sudo pacman -S --needed --noconfirm clang
sudo pacman -S --needed --noconfirm gcc
sudo pacman -S --needed --noconfirm git
sudo pacman -S --needed --noconfirm make
sudo pacman -S --needed --noconfirm ncurses
sudo pacman -S --needed --noconfirm flex
sudo pacman -S --needed --noconfirm bison
sudo pacman -S --needed --noconfirm gperf
sudo pacman -S --needed --noconfirm zsh
sudo pacman -S --needed --noconfirm fzf
sudo pacman -S --needed --noconfirm wireshark-cli
sudo pacman -S --needed --noconfirm zip
sudo pacman -S --needed --noconfirm unzip
sudo pacman -S --needed --noconfirm rar
sudo pacman -S --needed --noconfirm conky
sudo pacman -S --needed --noconfirm cmatrix
sudo pacman -S --needed --noconfirm btop
sudo pacman -S --needed --noconfirm go
sudo pacman -S --needed --noconfirm grub
sudo pacman -S --needed --noconfirm thunar
sudo pacman -S --needed --noconfirm brightnessctl
sudo pacman -S --needed --noconfirm hyprshot
sudo pacman -S --needed --noconfirm hyprpicker

# Apps
yay -S --needed --noconfirm brave-bin
yay -S --needed --noconfirm zed
yay -S --needed --noconfirm cava
yay -S --needed --noconfirm yazi
yay -S --needed --noconfirm tty-clock

# ZED custom THEME
sudo mkdir ./.config/zed
sudo mkdir ./.config/zed/themes

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Restart
sudo systemctl daemon-reexec
