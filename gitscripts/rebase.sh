source ~/.gitscripts/get-branch.sh

git rebase -i $(get_branch $1)
