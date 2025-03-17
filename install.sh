#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root (using sudo)."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME=$(eval echo ~$SUDO_USER)

# Update system
echo "Updating system..."
pacman -Syu --noconfirm

# Ask user if they are installing on an NVIDIA system
read -p "Are you installing on a system with an NVIDIA GPU? (yes/no): " nvidia_choice

# Install required packages
echo "Installing DWM package dependencies..."
pacman -S --needed --noconfirm \
    thunar xorg-server xorg-xinit xorg-xrandr xorg-xsetroot feh picom gdm starship \
    pavucontrol ttf-hack-nerd ttf-nerd-fonts-symbols pamixer gamemode rofi flameshot wget \
    zsh timeshift pipewire pipewire-pulse pipewire-alsa \
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

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "yay not found. Installing yay..."
    pacman -S --needed --noconfirm git base-devel
    sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay-bin.git "$USER_HOME/yay-bin"
    cd "$USER_HOME/yay-bin"
    sudo -u "$SUDO_USER" makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    rm -rf "$USER_HOME/yay-bin"
else
    echo "yay is already installed. Skipping installation."
fi

# Check if warp-terminal is installed
if ! pacman -Q warp-terminal-bin &> /dev/null; then
    echo "Installing warp-terminal from AUR..."
    sudo -u "$SUDO_USER" yay -S --noconfirm warp-terminal-bin
else
    echo "warp-terminal is already installed. Skipping installation."
fi

# Always install dwm from source
echo "Compiling and installing dwm from source..."
DWM_DIR="$SCRIPT_DIR/dwm"

if [[ ! -d "$DWM_DIR" ]]; then
    echo "Error: dwm directory not found inside dwm-arch. Exiting."
    exit 1
fi

cd "$DWM_DIR"
sudo make clean install
cd "$SCRIPT_DIR"

# Enable and start GDM
echo "Enabling GDM..."
systemctl enable gdm

# Prompt for Dotfile Installation
read -p "Do you want to install custom DWM dotfiles? (yes/no): " dotfiles_choice

if [[ "$dotfiles_choice" == "yes" ]]; then
    echo "Installing Stocky's DWM dotfiles..."
    
    # Ensure .config exists and copy configuration files
    mkdir -p "$USER_HOME/.config"
    cp -r "$SCRIPT_DIR/.config" "$USER_HOME/"
    
    # Copy .xprofile
    cp "$SCRIPT_DIR/.xprofile" "$USER_HOME/.xprofile"
    
    # Set correct permissions
    chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.config" "$USER_HOME/.xprofile"
    
    echo "Dotfiles installed successfully."
else
    echo "Skipping dotfile installation."
fi

# Ensure dwmblocks directory exists
DWM_BLOCKS_DIR="$SCRIPT_DIR/dwmblocks"

if [[ -d "$DWM_BLOCKS_DIR" ]]; then
    cd "$DWM_BLOCKS_DIR"
    
    # Apply custom config.h if exists
    if [[ -f "$DWM_BLOCKS_DIR/config.h" ]]; then
        echo "Applying custom config.h for dwmblocks..."
        cp "$DWM_BLOCKS_DIR/config.h" "$DWM_BLOCKS_DIR/config.h.bak" # Backup
    fi
    
    sudo make clean install
    cd "$SCRIPT_DIR"

    # Ensure dwmblocks starts on login
    if ! grep -q "dwmblocks &" "$USER_HOME/.xprofile"; then
        echo "Adding dwmblocks to startup..."
        echo "dwmblocks &" >> "$USER_HOME/.xprofile"
    fi
else
    echo "Warning: dwmblocks directory not found. Skipping installation."
fi

# Ask if user wants to copy the xrandr config
read -p "Do you want to keep the xrandr display setup? (yes/no): " xrandr_choice

if [[ "$xrandr_choice" == "no" ]]; then
    echo "Commenting out xrandr setup in .xprofile..."
    sed -i 's|^\(xrandr --output\)|# \1|' "$USER_HOME/.xprofile"
fi

echo "Installation complete."
