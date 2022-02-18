#!/bin/bash

remote_repo=origin
branch_current=$(git rev-parse --abbrev-ref HEAD)

git push -u ${remote_repo} ${branch_current} $1
echo "\033[1;32m${branch_current} has been set to upstream ${remote_repo}.\033[0m"
