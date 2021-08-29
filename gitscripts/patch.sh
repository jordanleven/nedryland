#!/bin/bash

PATCH_DIRECTORY_NAME=~/Desktop/

git add * > /dev/null
git diff --staged
echo "\033[33mPress \"y\" to proceed with this release or press any other key to abort.\033[0m\n"
read -p "" -n 1 -s

if [[ $REPLY =~ ^[Yy]$ ]]
then
  branch_name=$(git rev-parse --abbrev-ref HEAD)
  patch_file_name=patch_${branch_name};
  patch_file_name_path=${patch_file_name}.patch
  patch_file_name_zip=${patch_file_name}.zip
  git diff -p --staged > ${PATCH_DIRECTORY_NAME}${patch_file_name_path}
  pushd $PATCH_DIRECTORY_NAME
  zip -q -r ./${patch_file_name_zip} ./${patch_file_name_path}
  popd
  rm ${PATCH_DIRECTORY_NAME}${patch_file_name_path}
  echo "\033[1;32mPatch created at $PATCH_DIRECTORY_NAME${patch_file_name_zip}\033[0m"
else
  echo "\033[1;31mAborted\033[0m"
fi

git reset
