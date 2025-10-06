#!/usr/bin/env bash

# Only run on main display, not VNC
if [ "$DISPLAY" != ":0" ] && [ "$DISPLAY" != ":0.0" ]; then
  exit 0
fi

# Terminate already running bar instances
polybar-msg cmd quit

# Launch polybar on all monitors
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main &
  done
else
  polybar --reload main &
fi
