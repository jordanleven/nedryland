#!/bin/sh

get_current_application_bundle_id() {
  app_foreground=$(lsappinfo info --only BundleID "$(lsappinfo front)")
  app_foreground_name=$(echo "${app_foreground#*=}" | tr -d '"')
  echo "${app_foreground_name}"
}

get_git_editor_command_from_bundle_id() {
  case $1 in
    # VS Code
    com.microsoft.VSCode)
      echo "code --wait"
      ;;

    # Goland
    com.jetbrains.goland)
      echo "goland --wait"
      ;;

    # IntelliJ IDEA
    com.jetbrains.intellij)
      echo "idea --wait"
      ;;

    # Default to VS Code
    *)
      echo "code --wait"
      ;;
  esac
}

current_application=$(get_current_application_bundle_id)
git_editor_command=$(get_git_editor_command_from_bundle_id "$current_application")
$git_editor_command "$1"
