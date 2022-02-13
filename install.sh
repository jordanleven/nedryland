#!/bin/bash

current_directory=$(pwd)

function install_git_config {
  # Install gitscripts
  DIRECTORY_GIT='git'
  DIRECTORY_GIT_SCRIPTS='git-scripts'
  git config --global alias.patch "!sh $current_directory/$DIRECTORY_GIT/$DIRECTORY_GIT_SCRIPTS/patch.sh"
  git config --global alias.shake "!sh $current_directory/$DIRECTORY_GIT/$DIRECTORY_GIT_SCRIPTS/shake.sh"
  git config --global alias.pushup "!sh $current_directory/$DIRECTORY_GIT/$DIRECTORY_GIT_SCRIPTS/pushup.sh"
  git config --global alias.rebaso "!sh $current_directory/$DIRECTORY_GIT/$DIRECTORY_GIT_SCRIPTS/rebaso.sh"

  # Set the commit editor to VS Code
  git config --global core.editor "code --wait"

  # Set our directory for templates and hooks
  git config --global init.templatedir '~/.git_templates'

  # Copy the prepare-commit-msg to the global config
  cp $current_directory/$DIRECTORY_GIT/prepare-commit-msg ~/.git_templates/hooks/

  # Set our commit template
  git config --global commit.template $current_directory/$DIRECTORY_GIT/gitmessage
}

function install_oh_my_zsh_plugins {
  # Install Z
  git clone https://github.com/agkozak/zsh-z $ZSH/custom/plugins/zsh-z

  # Install Starship
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"

  printf "\n# Starship\n" >> ~/.zshrc
  printf 'eval "$(starship init zsh)"' >> ~/.zshrc
}

function install_custom_aliases_git {
  printf "\n# Custom Git aliases\n" >> ~/.zshrc
  printf 'alias gpp="git pull\n"' >> ~/.zshrc
  printf 'alias gpr="git pull --rebase\n"' >> ~/.zshrc
}

function install_custom_go_path {
  printf "\n# Custom Gopath\n" >> ~/.zshrc
  printf 'export GOPATH=~/.go' >> ~/.zshrc
}

install_git_config
install_oh_my_zsh_plugins
install_custom_aliases_git
install_custom_go_path
