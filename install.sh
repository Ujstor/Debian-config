#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list and update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# Making .config and Moving config files and background to Pictures
cd $builddir
mkdir -p /home/$username/.config
mkdir -p /home/$username/.fonts
mkdir -p /home/$username/Pictures
mkdir -p /home/$username/Pictures/backgrounds
cp -R dotconfig/* /home/$username/.config/
cp wallpaper.jpg /home/$username/Pictures/backgrounds/
mv user-dirs.dirs /home/$username/.config
chown -R $username:$username /home/$username

# Installing Essential Programs 
nala install feh kitty tmux rofi picom thunar nitrogen lxpolkit x11-xserver-utils unzip wget pipewire wireplumber  pulseaudio pavucontrol build-essential libx11-dev libxft-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev zoxide -y
# Installing Other less important Programs
nala install neofetch flameshot psmisc mangohud vim lxappearance papirus-icon-theme lxappearance fonts-noto-color-emoji gdu htop zoxide timeshift tldr git trash-cli autojump curl fzf -y

# Download Nordic Theme
cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git

# Installing fonts
cd $builddir 
nala install fonts-font-awesome -y
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip -d /home/$username/.fonts
mv dotfonts/fontawesome/otfs/*.otf /home/$username/.fonts/
chown $username:$username /home/$username/.fonts/*

# Reloading Font
fc-cache -vf
# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip ./JetBrainsMono.zip

# Install Nordzy cursor
git clone https://github.com/alvatip/Nordzy-cursors
cd Nordzy-cursors
./install.sh
cd $builddir
rm -rf Nordzy-cursors

# # Enable graphical login and change target from CLI to GUI
systemctl enable lightdm
systemctl set-default graphical.target

# Enable wireplumber audio service
sudo -u $username systemctl --user enable wireplumber.service

#install and config nvim tmux
sh <(curl -sSL https://raw.githubusercontent.com/Ujstor/tmux-config/master/install.sh) -y
sh <(curl -sSL https://raw.githubusercontent.com/Ujstor/nvim-config/master/install.sh) -y

# Beautiful bash
git clone https://github.com/Ujstor/mybash
cd mybash
sudo bash setup.sh -y
eval "$(starship init bash)"
cd $builddir

#scripts
bash scripts/vscode-gh
bash scripts/go
bash scripts/brave

#mount scripts
cp scripts/mount-menu.sh /usr/local/bin
chmod a+x /usr/local/bin/mount-menu.sh
cp scripts/umount-menu.sh /usr/local/bin
chmod a+x /usr/local/bin/umount-menu.sh

#nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh) -y

#nvidia drivers & cuda
bash scripts/nvidia-cuda

#docker
bash scripts/docker
cp config-files/docker-sock-permissions.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable docker-sock-permissions.service

#k8s
bash scripts/kubernetes

# DWM Setup
git clone https://github.com/ujstor/dwm
cd dwm
make clean install
cp dwm.desktop /usr/share/xsessions
cd $builddir


# Use nala
bash scripts/usenala
