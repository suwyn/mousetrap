#!/usr/bin/env bash

function Is.undefined {
  [ -z "${!1+x}" ]
}

function Window.name {
  xdotool getactivewindow getwindowclassname
}

function Time.now {
  date +%s
}

function Mousetrap.file {
  echo "$HOME/.mousetrap"
}

function Mousetrap.info {
  if Is.undefined "MOUSETRAP_INFO"; then
    head -1 "$(Mousetrap.file)" 2>/dev/null
  else
    echo "$MOUSETRAP_INFO"
  fi
}

function Mouse.at {
  xdotool getmouselocation --shell | tr '\n' ' '
}

# return the coordinates of the last mouse position
function Mouse.last_position {
  Mousetrap.info | cut -f4- -d' ' 2>/dev/null
}

# return the number of times activity was detected
function Mousetrap.activity {
  Mousetrap.info | cut -f1 -d' ' 2>/dev/null
}

# return the number of mouse movements detected
function Mousetrap.caught {
  Mousetrap.info | cut -f2 -d' ' 2>/dev/null
}

# return the time in ms when the trap was set
function Mousetrap.set_at {
  Mousetrap.info | cut -f3 -d' ' 2>/dev/null
}

function Mouse.moved {
  [ "$(Mouse.at)" != "$(Mouse.last_position)" ]
}

function Mousetrap.set {
  local activity=$1
  local caught=$2
  local set_at=$3
  local info

  info="$activity $caught $set_at $(Mouse.at)"

  echo "$info" > "$(Mousetrap.file)"
}

function Mousetrap.triggered {
  Mousetrap.tracking && Mouse.moved
}

function Mousetrap.cleanup {
  rm "$(Mousetrap.file)" 2>/dev/null
}

function Mousetrap.unset {
  local mousetrap=$1

  pkill -f "$mousetrap"
}

function Mousetrap.setup {
  Mousetrap.cleanup

  Mousetrap.set 0 0 "$(Time.now)"
}

function Mousetrap.tracking {
  [ "$(Window.name)" = "$(Mousetrap.current)" ]
}

function Mousetrap.watcher {
  pgrep -af "focus exec .+/mousetrap reset"
}

function Mousetrap.active {
  Mousetrap.watcher > /dev/null
}

# return the current application being watched
function Mousetrap.current {
  Mousetrap.watcher | rev | cut -d' ' -f1 | rev
}

function Mousetrap.hasActivity {
  Mousetrap.tracking && [ "$(xprintidle)" -lt 1000  ]
}

function Mousetrap.watch {
  local mouse=${1:-}

  if [ -z "$mouse" ]; then
    echo "A mouse is required to watch"
    exit 1
  fi

  xdotool search --onlyvisible --class "$mouse" behave %@ focus exec "$program" reset "$mouse"
}

# checks the mouse trap and returns a score
function Mousetrap.check {
  local activity caught idle=true

  # memoize the info to reduce file reads
  MOUSETRAP_INFO=$(Mousetrap.info)

  activity=$(Mousetrap.activity)
  if Mousetrap.hasActivity; then
    idle=false
    activity=$((activity + 1))
  fi

  caught=$(Mousetrap.caught)
  if Mousetrap.triggered; then
    idle=false
    caught=$((caught + 1))
  fi

  if ! $idle; then
    Mousetrap.set "$activity" "$caught" "$(Mousetrap.set_at)"
  fi

  echo "scale=2; (1 - $caught/$activity) * 100" | bc | xargs printf "%.0f"
}

function Mousetrap.log {
  local text=$1

  echo "$text" >> "$HOME/.mousetrap.log"
}
