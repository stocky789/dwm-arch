#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root (using sudo)."
    exit 1
fi

# Update system
echo "Updating system..."
pacman -Syu --noconfirm

# Install required packages
echo "Installing Thunar, xrandr, feh, picom, GDM, Starship, yay, and additional utilities..."
pacman -S --noconfirm thunar xorg-xrandr feh picom gdm starship pavucontrol pamixer rofi flameshot wget warp-terminal zsh dwm timeshift pipewire kitty

# Install yay (AUR helper)
echo "Installing yay..."
pacman -S --needed --noconfirm git base-devel
sudo -u $SUDO_USER git clone https://aur.archlinux.org/yay-bin.git /home/$SUDO_USER/yay-bin
cd /home/$SUDO_USER/yay-bin
sudo -u $SUDO_USER makepkg -si --noconfirm
cd ~
rm -rf /home/$SUDO_USER/yay-bin

# Enable and start GDM
echo "Enabling and starting GDM..."
systemctl enable gdm
systemctl start gdm

# Copy .xprofile file
echo "Copying .xprofile..."
cp "$(dirname "$0")/.xprofile" "/home/$SUDO_USER/.xprofile"
chmod +x "/home/$SUDO_USER/.xprofile"

# Copy wallpapers directory
echo "Copying wallpapers directory..."
mkdir -p "/home/$SUDO_USER/Pictures/"
cp -r "$(dirname "$0")/wallpapers" "/home/$SUDO_USER/Pictures/"
chown -R $SUDO_USER:$SUDO_USER "/home/$SUDO_USER/Pictures/wallpapers"

echo "Installation complete."
