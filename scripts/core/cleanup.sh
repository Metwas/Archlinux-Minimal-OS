#!/bin/bash

set -e

echo "== Removing orphan packages =="
orphans=$(pacman -Qtdq || true)
if [ -n "$orphans" ]; then
    sudo pacman -Rns --noconfirm $orphans
else
    echo "No orphans"
fi

echo
echo "== Cleaning package cache (keep latest) =="
sudo paccache -rk1
sudo paccache -ruk0

echo
echo "== Clearing user cache =="
rm -rf ~/.cache/*

echo
echo "== Clearing trash =="
rm -rf ~/.local/share/Trash/*

echo
echo "== Cleaning temp files =="
sudo find /tmp -mindepth 1 -delete
sudo find /var/tmp -mindepth 1 -delete

echo
echo "== Vacuuming journal =="
sudo journalctl --vacuum-time=3d

echo
echo "== Removing old logs =="
sudo find /var/log -type f -name "*.old" -delete
sudo find /var/log -type f -name "*.gz" -delete

echo
echo "== Syncing filesystem =="
sync

echo "Done."
