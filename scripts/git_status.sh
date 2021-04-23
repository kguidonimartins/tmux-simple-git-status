#!/usr/bin/env bash

PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}")
cd $PANE_PATH

git_changes() {
  local changes=$(git diff --shortstat | sed 's/^[^0-9]*\([0-9]*\)[^0-9]*\([0-9]*\)[^0-9]*\([0-9]*\)[^0-9]*/\1;\2;\3/')
  local changes_array=(${changes//;/ })
  local untracked=$(git status -sbu 2>/dev/null | grep -c "^??")
  local result=()

  if [[ $untracked != 0 ]]; then
    result+=("#[fg=green]?$untracked")
  fi

  # count modified files
  if [[ -n ${changes_array[0]} ]]; then
    result+=("#[fg=yellow]!${changes_array[0]}")
  fi

  # count added lines
  if [[ -n ${changes_array[1]} ]]; then
    result+=("#[fg=blue]+${changes_array[1]}")
  fi

  # count removed lines
  if [[ -n ${changes_array[2]} ]]; then
    result+=("#[fg=red]-${changes_array[2]}")
  fi

  local joined=$(printf " %s" "${result[@]}")
  local joined=${joined:1}

  if [[ -n $joined ]]; then
    echo "$joined "
  fi
}

git_status() {
  local status=$(git rev-parse --abbrev-ref HEAD)
  local ahead_behind="#[fg=white]$(git status -sb | head -n 1 | egrep -o "\[.*]" | sed "s/behind /⇣/g" | sed "s/ahead /⇡/g")"
  local changes=$(git_changes)

  if [[ -n $status ]]; then
    printf "#[fg=red]  $status $ahead_behind $changes"
  fi
}

main() {
  git_status
}

main
