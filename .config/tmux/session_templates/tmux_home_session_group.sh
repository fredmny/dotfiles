#!/bin/bash

PROJECTS_DIR="$HOME/shared_drive/projects"
DOTFILES_DIR="$HOME/dotfiles/.config"

create_base_repo_session() {
  local session="$1"
  local repo_dir="$2"
  local repo_type="$3"

  if [ ! -d "$repo_dir" ]; then
    echo "Error: Directory $repo_dir does not exist"
    return 1
  fi

  tmux has-session -t "$session" &> /dev/null
  if [ $? -eq 0 ]; then
    echo "Session '$session' already exists"
    return 0
  fi

  cd "$repo_dir" || return 1

  window_nr=0

  tmux new-session -s "$session" -n 'nvim' -d -c "$repo_dir"
  if [ $repo_type = "python" ]; then
    tmux send-keys -t "$session:$window_nr" 'source .venv/bin/activate' C-m
  fi
  tmux send-keys -t "$session:$window_nr" 'nvim' C-m

  window_nr=$((window_nr + 1))
  tmux new-window -t "$session:$window_nr" -n 'sh' -c "$repo_dir"
  tmux split-window -v -t "$session:$window_nr" -c "$repo_dir"

  window_nr=$((window_nr + 1))
  tmux new-window -t "$session:$window_nr" -n 'gh' -c "$repo_dir"
  tmux send-keys -t "$session:$window_nr" 'gh dash' C-m

  window_nr=9
  tmux new-window -t "$session:$window_nr" -n 'oc' -c "$repo_dir"
  if [ $repo_type = "python" ]; then
    tmux send-keys -t "$session:$window_nr" 'source .venv/bin/activate' C-m
  fi
  tmux send-keys -t "$session:$window_nr" 'opencode' C-m

  echo "Session '$session' created successfully"
}

create_dotfiles_session() {
  local session="dotfiles"

  if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Directory $DOTFILES_DIR does not exist"
    return 1
  fi

  tmux has-session -t "$session" &> /dev/null
  if [ $? -eq 0 ]; then
    echo "Session '$session' already exists"
    return 0
  fi

  cd "$DOTFILES_DIR" || return 1

  tmux new-session -s "$session" -n 'nvim' -d -c "$DOTFILES_DIR"
  tmux send-keys -t "$session:0" 'nvim' C-m

  tmux new-window -t "$session:1" -n 'sh' -c "$DOTFILES_DIR"

  echo "Session '$session' created successfully"
}


echo "Creating base repository sessions..."
create_base_repo_session "refugio-bot" "$PROJECTS_DIR/refugio_itapoa/whatsapp-bot" "node"
create_base_repo_session "refugio-agent" "$PROJECTS_DIR/refugio_itapoa/admin-agent" "python"

echo ""
echo "Creating dotfiles session..."
create_dotfiles_session

echo ""
echo "All sessions created!"
echo ""
echo "Available sessions:"
tmux list-sessions 2>/dev/null || echo "No sessions running"

echo "Attaching to tmux server"
tmux a

