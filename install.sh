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
    echo "Error: dwm directory not found. Exiting."
    exit 1
fi

cd "$DWM_DIR"
sudo make clean install
cd "$SCRIPT_DIR"

# Enable and start GDM
echo "Enabling and starting GDM..."
systemctl enable gdm
systemctl start gdm

# Install Stocky's personalized DOT files
echo "Installing Stocky's DWM DOT files..."

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

# Ask if user wants to copy the xrandr config
read -p "Do you want to keep the xrandr display setup? (yes/no): " xrandr_choice

if [[ "$xrandr_choice" == "no" ]]; then
    echo "Commenting out xrandr setup in .xprofile..."
    sed -i 's|^\(xrandr --output\)|# \1|' "$USER_HOME/.xprofile"
fi

# Copy Rofi theme
ROFI_THEME_SOURCE="$SCRIPT_DIR/rofi/themes/simple-tokyonight.rasi"
ROFI_THEME_TARGET="$USER_HOME/.local/share/rofi/themes"

echo "Installing Rofi theme..."
mkdir -p "$ROFI_THEME_TARGET"

if [[ -f "$ROFI_THEME_SOURCE" ]]; then
    cp "$ROFI_THEME_SOURCE" "$ROFI_THEME_TARGET/"
    chown "$SUDO_USER:$SUDO_USER" "$ROFI_THEME_TARGET/simple-tokyonight.rasi"
    echo "Rofi theme copied successfully."

    # Set Rofi theme in config
    ROFI_CONFIG="$USER_HOME/.config/rofi/config.rasi"
    mkdir -p "$USER_HOME/.config/rofi"
    echo 'configuration { theme: "~/.local/share/rofi/themes/simple-tokyonight.rasi"; }' > "$ROFI_CONFIG"
    chown "$SUDO_USER:$SUDO_USER" "$ROFI_CONFIG"

else
    echo "Warning: Rofi theme not found in $ROFI_THEME_SOURCE, skipping."
fi

# Ensure wallpaper is set on startup
echo "Setting default wallpaper..."
if ! grep -q "feh --bg-scale" "$USER_HOME/.xprofile"; then
    echo "feh --bg-scale /home/$SUDO_USER/Pictures/wallpapers/default.jpg &" >> "$USER_HOME/.xprofile"
fi

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
