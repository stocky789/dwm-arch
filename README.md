# DWM-Arch Installation Script

![DWM Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Dwm-logo.svg/1920px-Dwm-logo.svg.png)

## Overview
This script automates the installation and configuration of **dwm** (Dynamic Window Manager) on **Arch Linux**. It includes setting up essential dependencies, enabling a display manager, and applying a customized configuration.

## Features
- 🚀 Installs required system packages, fonts, and utilities.
- 🎮 Detects and installs NVIDIA drivers if applicable.
- 🛠 Ensures `yay` (AUR helper) is installed.
- 🔧 Builds and installs `dwm` and `dwmblocks` from source.
- 🔄 Enables `gdm` as the display manager.
- 🎨 Copies essential configuration files like `.xprofile` and Rofi themes.

![Arch Linux](https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Archlinux-logo-light-1200dpi.png/320px-Archlinux-logo-light-1200dpi.png)

## Prerequisites
- 🖥 **Arch Linux** installed (minimal install preferable).
- 🔑 **Root or sudo privileges**.
- 🌐 An active internet connection.

## Installation Instructions
### 1️⃣ Clone the Repository
   ```sh
   git clone https://github.com/your-username/dwm-arch.git
   cd dwm-arch
   ```

### 2️⃣ Run the Installation Script
   ```sh
   sudo ./install.sh
   ```

### 3️⃣ Follow the Prompts
   - ✅ Choose whether you are using an **NVIDIA GPU**.
   - ✅ Decide whether to keep the **xrandr display setup**.

## Post-Installation
- 🔄 Restart your system to apply all configurations:
  ```sh
  reboot
  ```
- 💻 After login, `dwm` should start automatically with `gdm`.
- ⚡ If `dwmblocks` is installed, it will run on startup.

## Uninstallation
To remove the installed files manually:
```sh
sudo pacman -Rns thunar xorg-server xorg-xinit xorg-xrandr xorg-xsetroot feh picom gdm starship \
    pavucontrol ttf-hack-nerd ttf-nerd-fonts-symbols pamixer gamemode rofi flameshot wget \
    zsh timeshift pipewire pipewire-pulse pipewire-alsa kitty lxappearance nm-connection-editor \
    ttf-font-awesome dunst
rm -rf ~/.config/dwm ~/.config/dwmblocks ~/.xprofile ~/.config/rofi
```

## ⚠️ Disclaimer
This script is designed for **Arch Linux** only. Use at your own risk! Always review the script before running it on your system.

## 🎉 Credits
This setup is based on personal configurations and improvements for a seamless `dwm` experience on Arch Linux. Contributions are welcome! 🚀