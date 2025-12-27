#!/bin/bash

# Package installation
sudo pacman -Sy archlinux-keyring
sudo pacman -Syyu

sudo pacman -Syy \
  gnome-keyring \
	npm \
  rust \
	rofi \
	neovim \
	nwg-look \
	tmux \
	waybar \
	zsh \
	zoxide \
	man-db \
	flameshot \
	fzf \
	hypridle \
	hyprpaper \
	hyprlock \
	ghostty \
	git \
  github-cli \
  base-devel \
  luarocks \
  lazygit

## Install yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

## Install aur packages
yay -S opencode-bin
yay -S ascii-image-converter-git

## Install other packages
curl -fsSL https://pkgs.netbird.io/install.sh | sh

# # Configure Displayling
# sudo pacman -Sy linux-headers # Might be necessary to replace with `linux-lts-headers`
# yay -S evdi-dkms
# yay -S displaylink
# sudo modprobe udl
# systemctl enable displayink.service
# systemctl start displayink.service

dotfiles_dir=$HOME/dotfiles
#
# Create config symlinks
create_config_symlink () {
	config_entry=$1
	ln -s ${dotfiles_dir}/.config/${config_entry}/ $HOME/.config/${config_entry}
}

mv .config/hypr .config/hypr.bkp
create_config_symlink hypr
create_config_symlink nvim
create_config_symlink rofi
create_config_symlink waybar
create_config_symlink ghostty
create_config_symlink flameshot
create_config_symlink lazygit
create_config_symlink tmux
create_config_symlink gh-dash

ln -s ${dotfiles_dir}/.aliases $HOME/.aliases
ln -s ${dotfiles_dir}/.tmux.conf $HOME/.tmux.conf
ln -s ${dotfiles_dir}/.zshrc $HOME/.zshrc


# Configure nvim

# TODO: Add to script
# - oh-my-zsh install
# - powerlevel10k install
# - yay install
