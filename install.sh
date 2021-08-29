#!/bin/bash

current_directory=$(pwd)

function install_git_config {
  # Install gitscripts
  DIRECTORY_GIT_SCRIPTS='gitscripts'
  git config --global alias.patch "!sh $current_directory/$DIRECTORY_GIT_SCRIPTS/patch.sh"
  git config --global alias.shake "!sh $current_directory/$DIRECTORY_GIT_SCRIPTS/shake.sh"
  git config --global alias.pushup "!sh $current_directory/$DIRECTORY_GIT_SCRIPTS/pushup.sh"
  git config --global alias.rebaso "!sh $current_directory/$DIRECTORY_GIT_SCRIPTS/rebaso.sh"

  # Set the commit editor to VS Code
  git config --global core.editor "code --wait"
}

function install_oh_my_zsh_plugins {
  # Install Z
  git clone https://github.com/agkozak/zsh-z $ZSH/custom/plugins/zsh-z

  # Install Starship
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"

  printf "\n# Starship\n" >> ~/.zshrc
  printf 'eval "$(starship init zsh)"' >> ~/.zshrc
}

function install_custom_go_path {
  printf "\n# Custom Gopath\n" >> ~/.zshrc
  printf 'export GOPATH=~/.go' >> ~/.zshrc
}

install_git_config
install_oh_my_zsh_plugins
install_custom_go_path
