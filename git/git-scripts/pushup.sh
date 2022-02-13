#!/bin/bash

REMOTE_REPO=origin
branch_current=$(git rev-parse --abbrev-ref HEAD)

git push -u ${REMOTE_REPO} ${branch_current} $1
echo "\033[1;32m${branch_current} has been set to upstream ${REMOTE_REPO}.\033[0m"
