#!/bin/bash

source ${BASH_SOURCE%/*}/get-branch.sh

git rebase -i $(get_branch $1)
