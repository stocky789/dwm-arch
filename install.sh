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
    pavucontrol ttf-hack-nerd ttf-nerd-fonts-symbols pamixer rofi flameshot wget \
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

# Install yay (AUR helper)
echo "Installing yay..."
pacman -S --needed --noconfirm git base-devel
sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay-bin.git "$USER_HOME/yay-bin"
cd "$USER_HOME/yay-bin"
sudo -u "$SUDO_USER" makepkg -si --noconfirm
cd "$SCRIPT_DIR"
rm -rf "$USER_HOME/yay-bin"

# Install warp-terminal from AUR
echo "Installing warp-terminal from AUR..."
sudo -u "$SUDO_USER" yay -S --noconfirm warp-terminal

# Ask user how they want to install dwm
read -p "Do you want to install the official dwm package or compile from source? (official/source): " dwm_choice

if [[ "$dwm_choice" == "official" ]]; then
    echo "Installing dwm from Arch repo..."
    pacman -S --noconfirm dwm
elif [[ "$dwm_choice" == "source" ]]; then
    echo "Compiling and installing dwm from source..."
    DWM_DIR="$SCRIPT_DIR/dwm"

    if [[ ! -d "$DWM_DIR" ]]; then
        echo "Error: dwm directory not found. Exiting."
        exit 1
    fi

    cd "$DWM_DIR"
    sudo make clean install
    cd "$SCRIPT_DIR"
fi

# Enable and start GDM
echo "Enabling and starting GDM..."
systemctl enable gdm
systemctl start gdm

# Ask user if they want to install Stocky's personalized DOT files
read -p "Do you want to install Stocky's personalized DOT files for DWM? (yes/no): " stocky_choice

if [[ "$stocky_choice" == "yes" ]]; then
    echo "Installing Stocky's DWM DOT files..."
    
    # Ensure dwmblocks directory exists
    DWM_BLOCKS_DIR="$SCRIPT_DIR/dwmblocks"

    if [[ ! -d "$DWM_BLOCKS_DIR" ]]; then
        echo "Error: dwmblocks directory not found. Exiting."
        exit 1
    fi

    cd "$DWM_BLOCKS_DIR"
    sudo make install
    cd "$SCRIPT_DIR"

    # Copy .xprofile from project root directory to user home
    XPROFILE_SOURCE="$SCRIPT_DIR/.xprofile"
    XPROFILE_TARGET="$USER_HOME/.xprofile"

    if [[ -f "$XPROFILE_SOURCE" ]]; then
        echo "Copying .xprofile to user home directory..."
        cp "$XPROFILE_SOURCE" "$XPROFILE_TARGET"
        chown "$SUDO_USER:$SUDO_USER" "$XPROFILE_TARGET"
        chmod +x "$XPROFILE_TARGET"
    else
        echo "Warning: .xprofile file not found in the project root."
    fi
fi

# Ensure wallpaper is set on startup
echo "Setting default wallpaper..."
echo "feh --bg-scale /home/$SUDO_USER/Pictures/wallpapers/default.jpg &" >> "$USER_HOME/.xprofile"

# Copy wallpapers directory from project root
echo "Copying wallpapers directory..."
WALLPAPER_SOURCE="$SCRIPT_DIR/wallpapers"
WALLPAPER_TARGET="$USER_HOME/Pictures/wallpapers"

mkdir -p "$WALLPAPER_TARGET"

if [[ -d "$WALLPAPER_SOURCE" ]]; then
    cp -r "$WALLPAPER_SOURCE" "$USER_HOME/Pictures/"
else
    echo "Warning: wallpapers directory not found, skipping."
fi

chown -R "$SUDO_USER:$SUDO_USER" "$WALLPAPER_TARGET"

echo "Installation complete."
