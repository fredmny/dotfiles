#!/bin/bash

session="work"

# Check if session already exists
tmux has-session -t $session &> /dev/null

# Creates new session just if session with same name doesn't already exist
if [ $? != 0 ]; then
  
  # Window 0
  tmux new-session -s $session -n 'nvim' -d
  tmux send-keys -t $session:0 'ssh-add ~/.ssh/github' C-m
  tmux send-keys -t $session:0 'cd ~/personal/dotfiles/.config/nvim && nvim' C-m
  
  # Window 1  
  tmux new-window -t $session:1 -n 'sh'

  # Window 2  
  tmux new-window -t $session:2 -n 'dp-nvim'
  tmux send-keys -t $session:2 'cd ~/brm_repos/datalake-pipelines-workdir/datalake-pipelines && sp && nvim' C-m
  tmux split-window -v -t $session:2
  tmux send-keys -t $session:2 'cd ~/brm_repos/datalake-pipelines-workdir/datalake-pipelines' C-m
  tmux resize-pane -D -t $session:2.0 -y 200

  # Window 3
  tmux new-window -t $session:3 -n 'db-sh'
  tmux send-keys -t $session:3 'cd ~/brm_repos/datalake-pipelines-workdir' C-m
  tmux send-keys -t $session:3 'cd ~/brm_repos/datalake-pipelines-workdir/datalake-pipelines/ && sp && cd dagster/brm_general' C-m
  tmux split-window -v -t $session:3
  tmux send-keys -t $session:3 'cd ~/brm_repos/datalake-pipelines-workdir/datalake-pipelines/ && sp && cd dbt_project' C-m
  tmux send-keys -t $session:3 'clear' C-m

  # Window 3  

  # Window 4

  # Window 7
  tmux new-window -t $session:7 -n 'docker'
  tmux send-keys -t $session:7 'lazydocker' C-m

  # Window 8
  tmux new-window -t $session:8 -n 'k8s'
  tmux send-keys -t $session:8 'k9s' C-m

fi

tmux attach-session -t $session:0
tmux resize-pane -D -t $session:2.0 -y 70%
