#!/bin/sh

patch_directory_name=~/Desktop/

git add * > /dev/null
git diff --staged
printf "\033[33mPress \"y\" to proceed with this release or press any other key to abort.\033[0m\n"
read -r "" -n 1 -s
if echo "$REPLY" | grep -q "^[Yy]$"
then
  branch_name=$(git rev-parse --abbrev-ref HEAD)
  branch_name_sanitized=$(echo "$branch_name" | sed -e 's/\//_/g')
  patch_file_name=patch_${branch_name_sanitized}
  patch_file_name_path=${patch_file_name}.patch
  patch_file_name_zip=${patch_file_name}.zip
  git diff -p --staged > "${patch_directory_name}${patch_file_name_path}"
  pushd $patch_directory_name || exit 1
  zip -q -r ./"$patch_file_name_zip" ./"$patch_file_name_path"
  popd
  rm "${patch_directory_name}${patch_file_name_path}"
  printf "\033[1;32mPatch created at %s%s\033[0m\n" "$patch_directory_name" "$patch_file_name_zip"
else
  printf "\033[1;31mAborted\033[0m\n"
fi
