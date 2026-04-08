#!/bin/zsh

FORCE_REFRESH_DOWNLOADS_DIR="$HOME/Downloads"
FORCE_REFRESH_QA_DIR="$HOME/Developer/Personal/force-refresh/qa"
FORCE_REFRESH_BUILD_PREFIX="force-refresh"

force_refresh_find_build() {
  find "$FORCE_REFRESH_DOWNLOADS_DIR" -maxdepth 1 -type d -name "${FORCE_REFRESH_BUILD_PREFIX}*" | head -1
}

force_refresh_clear_qa_dir() {
  echo "Clearing QA directory..."
  find "$FORCE_REFRESH_QA_DIR" -mindepth 1 -not -name ".gitkeep" -delete
}

force_refresh_install_build() {
  local build_folder="$1"
  echo "Copying build contents..."
  cp -r "$build_folder/." "$FORCE_REFRESH_QA_DIR/"
}

force_refresh_remove_download() {
  local build_folder="$1"
  echo "Removing downloaded folder..."
  rm -rf "$build_folder"
}

force_refresh_qa() {
  local build_folder
  build_folder=$(force_refresh_find_build)

  if [[ -z "$build_folder" ]]; then
    echo "\033[1;31mNo ${FORCE_REFRESH_BUILD_PREFIX} folder found in ${FORCE_REFRESH_DOWNLOADS_DIR}.\033[0m"
    return 1
  fi

  echo "\033[1;32mFound build: $(basename "$build_folder")\033[0m"

  force_refresh_clear_qa_dir
  force_refresh_install_build "$build_folder"
  force_refresh_remove_download "$build_folder"

  echo "\033[1;32mDone. $(basename "$build_folder") installed to ${FORCE_REFRESH_QA_DIR}.\033[0m"
}

alias copy-force-refresh="force_refresh_qa"
