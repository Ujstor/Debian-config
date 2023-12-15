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
cp bg.jpg /home/$username/Pictures/backgrounds/
mv user-dirs.dirs /home/$username/.config
chown -R $username:$username /home/$username

# Installing Essential Programs 
nala install feh kitty tmux rofi picom thunar nitrogen lxpolkit x11-xserver-utils unzip wget pulseaudio pavucontrol build-essential libx11-dev libxft-dev libxinerama-dev -y
# Installing Other less important Programs
nala install neofetch flameshot psmisc mangohud vim neovim lxappearance papirus-icon-theme lxappearance fonts-noto-color-emoji lightdm gdu htop -y

#install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh --dry-run
nala install -y nvidia-container-toolki

#install vscode
nala install dirmngr ca-certificates software-properties-common apt-transport-https curl -y
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg >/dev/null
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
nala update
nala install code

#install gh
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo nala update \
&& sudo nala install gh -y

#Install go
download_dir="$HOME/Downloads"
go_version="go1.20.2"
go_url="https://golang.org/dl/${go_version}.linux-amd64.tar.gz"

wget -P "$download_dir" "$go_url"
sudo tar -C /usr/local -xzf "${download_dir}/${go_version}.linux-amd64.tar.gz"
echo "export PATH=/usr/local/go/bin:\${PATH}" | sudo tee -a "$HOME/.profile"
source "$HOME/.profile"

#lazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

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
mv dotfonts/fontawesome/otfs/*.otf /home/$username/.fonts/
chown $username:$username /home/$username/.fonts/*

# Reloading Font
fc-cache -vf
# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip

# Install Nordzy cursor
git clone https://github.com/alvatip/Nordzy-cursors
cd Nordzy-cursors
./install.sh
cd $builddir
rm -rf Nordzy-cursors

# Install brave-browser
nala install apt-transport-https curl -y
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
nala update
nala install brave-browser -y

# Enable graphical login and change target from CLI to GUI
systemctl enable lightdm
systemctl set-default graphical.target

# Beautiful bash
git clone https://github.com/Ujstor/mybash
cd mybash
bash setup.sh
cd $builddir

# Use nala
bash scripts/usenala
