#!/bin/zsh

TEMP_DIRECTORY_PREFIX="nedryland.tmpdir"
PERSISTED_DIRECTORY=~/Desktop

nedryland_cleanup_temp_directory() {
  echo "\033[1;31mRemoving temporary directory...\033[0m"
  test -d "${1}" && rm -fr "${1}"
  sleep 2
}

nedryland_create_temp_directory() {
  temp_directory_path=$(mktemp -d -t ${TEMP_DIRECTORY_PREFIX})
  temp_directory_name=$(basename $temp_directory_path)
  cd "${temp_directory_path}" > /dev/null


  zshexit() {
    nedryland_cleanup_temp_directory $temp_directory_path
  }

  echo "\033[1;32mTemporary directory created at ${temp_directory_name}.\n\033[0m"
  echo "\033[1;31mExiting this sessions will destroy this directory. To keep this directory, run `persistdir`.\033[0m"
}

nedryland_persist_temp_directory() {
  current_directory=$(pwd)
  if [[ "${current_directory}" =~ $TEMP_DIRECTORY_PREFIX ]]
  then
    mv $current_directory $PERSISTED_DIRECTORY
    cd $PERSISTED_DIRECTORY
    echo "\033[1;32mDirectory moved to Desktop.\033[0m"
  else
    echo "\033[1;31mCurrent directory is not temporary directory.\033[0m"
  fi
}
