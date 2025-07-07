#!/bin/bash

session="$1"

if [ -z "$session" ]; then
  echo "Error: No session name provided."
  exit 1
fi

echo "Session name: $session"

# Check if session already exists
tmux has-session -t "$session" &> /dev/null
session_exists=$?

# Create new session only if it doesn't already exist
if [ $session_exists -ne 0 ]; then
  window_nr=0

  # Window 0
  tmux new-session -s "$session" -n 'nvim' -d
  tmux send-keys -t "$session:$window_nr" 'ssh-add ~/.ssh/github' C-m
  tmux send-keys -t "$session:$window_nr" 'nvim' C-m

  # Window 1
  window_nr=$((window_nr + 1))
  tmux new-window -t "$session:$window_nr" -n 'sh'
  tmux split-window -v -t "$session:$window_nr"

  # Window 2
  window_nr=$((window_nr + 1))
  tmux new-window -t "$session:$window_nr" -n 'gh'
  tmux send-keys -t "$session:$window_nr" 'gh dash' C-m

  # Window 7
  window_nr=7
  tmux new-window -t "$session:$window_nr" -n 'docker'
  tmux send-keys -t "$session:$window_nr" 'lazydocker' C-m

  # Window 8
  window_nr=8
  tmux new-window -t "$session:$window_nr" -n 'k8s'
  tmux send-keys -t "$session:$window_nr" 'k9s' C-m

  echo "Session '$session' created successfully"

else
  echo "Sesssion '$session' already exists"
fi


tmux attach-session -t "$session"
