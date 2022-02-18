#!/bin/zsh
source ~/.zshrc

current_directory=$(pwd)

function command_does_exist {
  if command -v $1 &> /dev/null
  then
    return 0
  else
    return 1
  fi
}

function install_git_config {
  # Install gitscripts
  DIRECTORY_GIT='git'
  DIRECTORY_GIT_SCRIPTS='git-scripts'
  git config --global alias.patch "!zsh $current_directory/$DIRECTORY_GIT/$DIRECTORY_GIT_SCRIPTS/patch.sh"
  git config --global alias.shake "!zsh $current_directory/$DIRECTORY_GIT/$DIRECTORY_GIT_SCRIPTS/shake.sh"
  git config --global alias.pushup "!zsh $current_directory/$DIRECTORY_GIT/$DIRECTORY_GIT_SCRIPTS/pushup.sh"
  git config --global alias.rebaso "!zsh $current_directory/$DIRECTORY_GIT/$DIRECTORY_GIT_SCRIPTS/rebaso.sh"

  # Set the commit editor to VS Code
  git config --global core.editor "code --wait"

  # Set our directory for templates and hooks
  git config --global init.templatedir '~/.git_templates'

  # Set our commit template
  git config --global commit.template $current_directory/$DIRECTORY_GIT/gitmessage
}

function install_git_hooks {
  # Copy the prepare-commit-msg to the global config
  cp $current_directory/$DIRECTORY_GIT/prepare-commit-msg ~/.git_templates/hooks/
}

function install_oh_my_zsh_plugins {
  # Install Z
  git clone https://github.com/agkozak/zsh-z $ZSH/custom/plugins/zsh-z

  # Install Starship
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"

  printf "\n# Starship\n" >> ~/.zshrc
  printf 'eval "$(starship init zsh)"' >> ~/.zshrc
}

function install_custom_aliases {
  printf "\n# Custom aliases\n" >> ~/.zshrc
  printf "source $current_directory/zshell/zshell.aliases.sh\n" >> ~/.zshrc
}

function install_custom_go_path {
  printf "\n# Custom Gopath\n" >> ~/.zshrc
  printf 'export GOPATH=~/.go' >> ~/.zshrc
}

function prompt_user_for_update {
  prompt=$1
  function=$2
  echo -e "\n\x1b[1;38;32;97;188;101mUpdate $prompt? \x1b[38;2;97;188;101m[y/n]\033[0m"
  read -q -s
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    $function
  else
    echo -e "\x1b[3;38;32;97;188;101mSkipping $prompt update...\033[0m"
  fi
}

function nedryland_init {
  install_git_config
  install_git_hooks
  install_oh_my_zsh_plugins
  install_custom_aliases
  install_custom_go_path
}

function nedryland_update {
  prompt_user_for_update "git config" install_git_config
  prompt_user_for_update "git hooks" install_git_hooks
}

# Check if we need to do an initial install of Nedryland
if ! command_does_exist nedryland
then
  nedryland_init
else
  echo -e "\n\x1b[1;38;2;255;63;63mNedryland has already been installed. Running updates...\033[0m"
  nedryland_update
fi

nedryland
