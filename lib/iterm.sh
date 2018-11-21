#!/usr/bin/env bash

# Launch iTerm or bring to front if already running
function iterm_launch() {
  /usr/bin/osascript <<-EOF
  if application "iTerm" is running then
    tell application "iTerm"
      create window with default profile
    end tell
  else
    activate application "iTerm"
  end if
EOF
}


function getSplitDirection() {
  local DIR="${1:-v}"
  case $DIR in
    vertically|v)
      DIR="vertically"
      ;;
    horizontally|h)
      DIR="horizontally"
      ;;
    *)
      DIR="vertically"
      ;;
  esac
  echo $DIR
}

function iterm_addSplit() {
  local DIR
  DIR=$(getSplitDirection "${1:-v}")

  /usr/bin/osascript <<-EOF
  tell application "iTerm"
    tell current session of current window
      split $DIR with default profile
      delay 1
    end tell
  end tell
EOF
}

function iterm_nextPane() {
  /usr/bin/osascript <<-EOF
  tell application "iTerm"
    tell application "System Events" to keystroke "]" using command down
  end tell
EOF
}

function iterm_clear() {
  /usr/bin/osascript <<-EOF
  tell application "iTerm"
    tell application "System Events" to keystroke "k" using command down
  end tell
EOF
}


function iterm_write() {
  local CMD="${1:-ls}"

  /usr/bin/osascript <<-EOF
  tell application "iTerm"
    tell current session of current window
      write text "$CMD"
    end tell
  end tell
EOF
}
