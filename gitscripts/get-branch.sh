source ~/.gitscripts/production-branch.sh

function get_branch {
  if [ -n "$1" ]; then
    echo $1
  else
    echo $(git_main_branch)
  fi
}
