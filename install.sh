#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root (using sudo)."
    exit 1
fi

# Update system
echo "Updating system..."
pacman -Syu --noconfirm

# Ask user if they are installing on an NVIDIA system
read -p "Are you installing on a system with an NVIDIA GPU? (yes/no): " nvidia_choice

# Install required packages
echo "Installing DWM package dependencies..."
pacman -S --noconfirm \
    thunar xorg-server xorg-xinit xorg-xrandr xorg-xsetroot feh picom gdm starship \
    pavucontrol ttf-hack-nerd ttf-nerd-fonts-symbols pamixer rofi flameshot wget \
    warp-terminal zsh dwm timeshift pipewire pipewire-pulse pipewire-alsa \
    kitty lxappearance nm-connection-editor ttf-font-awesome dunst

# Install NVIDIA drivers if selected
if [[ "$nvidia_choice" == "yes" ]]; then
    echo "Installing NVIDIA drivers with the open kernel..."
    pacman -S --noconfirm nvidia-open nvidia-utils nvidia-settings lib32-nvidia-utils
    echo "Enabling NVIDIA DRM Modeset..."
    echo 'options nvidia NVreg_UsePageAttributeTable=1' > /etc/modprobe.d/nvidia.conf
    echo 'options nvidia_drm modeset=1' > /etc/modprobe.d/nvidia-drm.conf
    mkinitcpio -P
fi

# Install yay (AUR helper)
echo "Installing yay..."
USER_HOME=$(eval echo ~$SUDO_USER)
pacman -S --needed --noconfirm git base-devel
sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay-bin.git "$USER_HOME/yay-bin"
cd "$USER_HOME/yay-bin"
sudo -u "$SUDO_USER" makepkg -si --noconfirm
cd ~
rm -rf "$USER_HOME/yay-bin"

# Enable and start GDM
echo "Enabling and starting GDM..."
systemctl enable gdm
systemctl start gdm

# Ask user if they want to install Stocky's personalized DOT files
read -p "Do you want to install Stocky's personalized DOT files for DWM? (yes/no): " stocky_choice

if [[ "$stocky_choice" == "yes" ]]; then
    echo "Installing Stocky's DWM DOT files..."
    cd "$(dirname "$0")/dwm" || { echo "Error: dwm directory not found."; exit 1; }
    sudo make install
    cd ../dwmblocks || { echo "Error: dwmblocks directory not found."; exit 1; }
    sudo make install
    cd ..
    cp .xprofile "$USER_HOME/.xprofile"
    chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/.xprofile"
    chmod +x "$USER_HOME/.xprofile"
fi

# Ensure wallpaper is set on startup
echo "Setting default wallpaper..."
echo "feh --bg-scale /home/$SUDO_USER/Pictures/wallpapers/default.jpg &" >> "/home/$SUDO_USER/.xprofile"

# Copy wallpapers directory
echo "Copying wallpapers directory..."
mkdir -p "/home/$SUDO_USER/Pictures/"
cp -r "$(dirname "$0")/wallpapers" "/home/$SUDO_USER/Pictures/"
chown -R $SUDO_USER:$SUDO_USER "/home/$SUDO_USER/Pictures/wallpapers"

echo "Installation complete."
