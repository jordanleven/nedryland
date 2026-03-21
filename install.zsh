#!/bin/zsh

. ~/.zshrc
. "$(dirname "$0")/zshell/zshell.nedryland.zsh"

install_current_directory=$(pwd)
typeset -a install_summary

record_install_summary() {
  install_summary+=("$1")
}

print_install_summary() {
  printf "\n\x1b[1;37mInstall summary\x1b[0m\n"

  if [ ${#install_summary[@]} -eq 0 ]
  then
    printf "\x1b[38;2;160;160;160m- No changes were recorded.\x1b[0m\n"
    return
  fi

  for summary_line in "${install_summary[@]}"
  do
    printf "%b\n" "$summary_line"
  done
}

run_install_step() {
  step_label=$1
  shift

  "$@"
  step_status=$?

  case $step_status in
    0)
      record_install_summary "\x1b[38;2;97;188;101m- Completed:\x1b[0m $step_label"
      return 0;;
    1)
      record_install_summary "\x1b[38;2;210;80;80m- Skipped:\x1b[0m $step_label"
      return 0;;
    130)
      record_install_summary "\x1b[1;38;2;255;63;63m- Aborted:\x1b[0m $step_label"
      return 130;;
    *)
      record_install_summary "\x1b[1;38;2;255;63;63m- Failed:\x1b[0m $step_label"
      return $step_status;;
  esac
}

run_optional_install_step() {
  step_label=$1
  shift

  prompt_user_for_update "$step_label"
  prompt_status=$?

  case $prompt_status in
    0)
      run_install_step "$step_label" "$@"
      return $?;;
    1)
      record_install_summary "\x1b[38;2;210;80;80m- Skipped:\x1b[0m $step_label"
      return 0;;
    130)
      record_install_summary "\x1b[1;38;2;255;63;63m- Aborted:\x1b[0m $step_label"
      return 130;;
    *)
      return $prompt_status;;
  esac
}

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
  git config --global alias.patch "!sh $install_current_directory/$directory_git/$directory_git_scripts/patch.sh"
  git config --global alias.shake "!sh $install_current_directory/$directory_git/$directory_git_scripts/shake.sh"
  git config --global alias.pushup "!sh $install_current_directory/$directory_git/$directory_git_scripts/pushup.sh"
  git config --global alias.rebaso "!sh $install_current_directory/$directory_git/$directory_git_scripts/rebaso.sh"
  git config --global alias.remove-beta "!sh $install_current_directory/$directory_git/$directory_git_scripts/remove-beta.sh"

  # Set the commit editor to the foreground app
  git config --global core.editor "$install_current_directory/$directory_git/$directory_git_scripts/editor-from-foreground-app.sh"

  # Set our directory for templates and hooks
  git config --global init.templatedir "$HOME/.git_templates"

  # Set our commit template
  git config --global commit.template "$install_current_directory/$directory_git"/gitmessage

  # For pulling divergent branches
  git config --global pull.rebase true
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

install_nedryland_greeting() {
  if ! zsh_config_does_exist "# Nedryland Greeting"
  then
  {
    printf "\n# Nedryland Greeting\n"
    nedryland_loaded
  } >> ~/.zshrc
  fi
}

install_claude_skills() {
  shared_skills_source="$install_current_directory/skills"
  claude_skills_target="$HOME/.claude/skills"

  mkdir -p "$HOME/.claude"

  if [ ! -e "$claude_skills_target" ]
  then
    ln -s "$shared_skills_source" "$claude_skills_target"
  fi
}

sync_codex_skill_links() {
  shared_skills_source="$install_current_directory/skills"
  codex_skills_target="$HOME/.codex/skills"

  mkdir -p "$codex_skills_target"

  for skill_path in "$shared_skills_source"/*
  do
    if [ -d "$skill_path" ]
    then
      skill_name=$(basename "$skill_path")
      codex_skill_link="$codex_skills_target/$skill_name"
      if [ ! -e "$codex_skill_link" ]
      then
        ln -s "$skill_path" "$codex_skill_link"
      fi
    fi
  done

  for codex_skill_link in "$codex_skills_target"/*
  do
    if [ -L "$codex_skill_link" ]
    then
      linked_skill_path=$(readlink "$codex_skill_link")
      expected_skill_path="$shared_skills_source/$(basename "$codex_skill_link")"
      if [ "$linked_skill_path" = "$expected_skill_path" ] && [ ! -d "$expected_skill_path" ]
      then
        rm "$codex_skill_link"
      fi
    fi
  done
}

install_shared_skills() {
  install_claude_skills
  sync_codex_skill_links
}

install_gh_cli() {
  if ! command_does_exist gh
  then
    brew install gh
    gh config set editor "$install_current_directory/$directory_git/$directory_git_scripts/editor-from-foreground-app.sh"
  fi
}

prompt_user_for_update() {
  prompt=$1
  selected_option="yes"
  prompt_emoji="❓"
  prompt_hint="\x1b[2;38;2;196;147;58mUse ← → to switch • Enter to confirm • Esc to abort\x1b[0m"
  prompt_has_rendered=0

  clear_prompt_block() {
    printf "\033[3A\r\033[K\033[1B\r\033[K\033[1B\r\033[K\033[2A\r"
  }

  case "$prompt" in
    *git\ config* )
      prompt_emoji="⚙️";;
    *git\ hooks* )
      prompt_emoji="🪝";;
    *Claude* )
      prompt_emoji="🧠";;
    *Codex* )
      prompt_emoji="🤖";;
  esac

  while true
  do
    if [ "$selected_option" = "yes" ]
    then
      yes_option="\x1b[1;30;48;2;97;188;101m YES \x1b[0m"
      no_option="\x1b[1;38;2;210;80;80m NO \x1b[0m"
    else
      yes_option="\x1b[1;38;2;97;188;101m YES \x1b[0m"
      no_option="\x1b[1;30;48;2;210;80;80m NO \x1b[0m"
    fi

    if [ "$prompt_has_rendered" -eq 1 ]
    then
      clear_prompt_block
    else
      prompt_has_rendered=1
    fi

    printf "\r\033[K%b \x1b[1;37mUpdate %s?\x1b[0m\n\033[K  %b   %b\n\033[K  %b\n" "$prompt_emoji" "$prompt" "$yes_option" "$no_option" "$prompt_hint"

    read -rsk1 reply

    case $reply in
      [Yy] )
        clear_prompt_block
        return 0;;
      [Nn] )
        clear_prompt_block
        return 1;;
      " " | "" | $'\n' | $'\r' )
        clear_prompt_block
        if [ "$selected_option" = "yes" ]
        then
          return 0
        else
          return 1
        fi;;
      $'\e' )
        if read -rsk1 -t 0.01 next_key
        then
          if [ "$next_key" = "[" ]
          then
            read -rsk1 arrow_key
            case $arrow_key in
              C )
                selected_option="no";;
              D )
                selected_option="yes";;
            esac
          fi
        else
          clear_prompt_block
          return 130
        fi;;
    esac
  done
}

nedryland_init() {
  run_install_step "git config" install_git_config || return $?
  run_install_step "git hooks" install_git_hooks || return $?
  run_install_step "Oh My Zsh plugins" install_oh_my_zsh_plugins || return $?
  run_install_step "custom aliases" install_custom_aliases || return $?
  run_install_step "custom GOPATH" install_custom_go_path || return $?
  run_install_step "Nedryland greeting" install_nedryland_greeting || return $?
  run_install_step "GitHub CLI" install_gh_cli || return $?
  run_install_step "shared skills" install_shared_skills || return $?
}

nedryland_update() {
  run_optional_install_step "git config" install_git_config || return $?
  run_optional_install_step "git hooks" install_git_hooks || return $?
  run_optional_install_step "Claude shared skills" install_claude_skills || return $?
  run_optional_install_step "Codex skill symlinks" sync_codex_skill_links || return $?
}

# Check if we need to do an initial install of Nedryland
if ! command_does_exist nedryland
then
  nedryland_init
  install_status=$?
else
  if [ "${NEDRYLAND_SUPPRESS_UPDATE_BANNER:-0}" != "1" ]
  then
    printf "\n\x1b[1;38;2;255;63;63mNedryland has already been installed. Running updates...\n\033[0m"
  fi
  nedryland_update
  install_status=$?
fi

if [ "$install_status" -eq 130 ]
then
  printf "\n\x1b[1;38;2;255;63;63mInstall aborted.\x1b[0m\n"
elif [ "$install_status" -eq 0 ]
then
  printf "\n\x1b[1;38;2;97;188;101mInstall complete.\x1b[0m\n"
else
  printf "\n\x1b[1;38;2;255;63;63mInstall failed.\x1b[0m\n"
fi

print_install_summary

exit "$install_status"
