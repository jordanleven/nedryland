#!/bin/zsh

. ~/.zshrc
. "$(dirname "$0")/zshell/zshell.nedryland.zsh"

install_current_directory=$(pwd)

command_does_exist() {
  if type "$1" &> /dev/null
  then
    return 0
  else
    return 1
  fi
}

zsh_config_does_exist() {
  zshrc=$HOME/.zshrc
  if grep -Fq "$1" "$zshrc"
  then
     return 0
  else
    return 1
  fi
}

install_git_config() {
  # Install gitscripts
  directory_git='git'
  directory_git_scripts='git-scripts'
  git config --global alias.patch "!zsh $install_current_directory/$directory_git/$directory_git_scripts/patch.zsh"
  git config --global alias.shake "!zsh $install_current_directory/$directory_git/$directory_git_scripts/shake.zsh"
  git config --global alias.pushup "!zsh $install_current_directory/$directory_git/$directory_git_scripts/pushup.zsh"
  git config --global alias.rebaso "!zsh $install_current_directory/$directory_git/$directory_git_scripts/rebaso.zsh"

  # Set the commit editor to VS Code
  git config --global core.editor "code --wait"

  # Set our directory for templates and hooks
  git config --global init.templatedir "$HOME/.git_templates"

  # Set our commit template
  git config --global commit.template "$install_current_directory/$directory_git"/gitmessage
}

install_git_hooks() {
  # Copy the prepare-commit-msg to the global config
  cp "$install_current_directory/$directory_git/prepare-commit-msg" "$HOME/.git_templates/hooks/"
}

install_oh_my_zsh_plugins() {
  oh_my_zsh_plugin_directory="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # Maybe install Z
  z_directory="$oh_my_zsh_plugin_directory/plugins/zsh-z"
  if [ ! -d "$z_directory" ]
  then
    git clone https://github.com/agkozak/zsh-z "$z_directory/plugins/zsh-z"
  fi

  # Maybe install Starship
  if ! zsh_config_does_exist "# Starship"
  then
    sh -c "$(curl -fsSL https://starship.rs/install.sh)"
    {
      printf "\n# Starship\n" >> ~/.zshrc
      printf "export STARSHIP_CONFIG=%s/zshell/starship.config.toml\n" "$install_current_directory"
      printf "eval \$(starship init zsh)\n"
    } >> ~/.zshrc
  fi;

  # Maybe install Zsh Autosuggestions
  zsh_autosuggestion_directory="$oh_my_zsh_plugin_directory/plugins/zsh-autosuggestions"
  if [ ! -d "$zsh_autosuggestion_directory" ]
  then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_autosuggestion_directory"
  fi
}

install_custom_aliases() {
  if ! zsh_config_does_exist "# Custom aliases"
  then
    {
      printf "\n# Custom aliases\n"
      printf "source %s/zshell/zshell.aliases.zsh\n" "$install_current_directory"
    } >> ~/.zshrc
  fi
}

install_custom_go_path() {
  if ! zsh_config_does_exist "# Custom Gopath"
  then
  {
    printf "\n# Custom Gopath\n"
    printf "export GOPATH=~/.go\n"
  } >> ~/.zshrc
  fi
}

install_gh_cli() {
  if ! command_does_exist gh
  then
    brew install gh
  fi
}

prompt_user_for_update() {
  prompt=$1
  while true
  do
    printf "\n\x1b[1;38;32;97;188;101mUpdate %s? \x1b[38;2;97;188;101m[y/n] \033[0m" "$prompt"
    read reply
    case $reply in
        [Yy]* )
          return 0
        break;;
        [Nn]* )
          printf "\x1b[3;38;32;97;188;101mSkipping %s update...\n\033[0m" "$prompt"
          return 1
          break;;
        * )
        printf "\n\x1b[1;38;2;255;63;63mPlease response with \"y\" or \"n\"\n\033[0m"
    esac
  done
}

nedryland_init() {
  install_git_config
  install_git_hooks
  install_oh_my_zsh_plugins
  install_custom_aliases
  install_custom_go_path
  install_gh_cli
}

nedryland_update() {
  prompt_user_for_update "git config" && install_git_config
  prompt_user_for_update "git hooks" && install_git_hooks
}

# Check if we need to do an initial install of Nedryland
if ! command_does_exist nedryland
then
  nedryland_init
else
  printf "\n\x1b[1;38;2;255;63;63mNedryland has already been installed. Running updates...\n\033[0m"
  nedryland_update
fi
