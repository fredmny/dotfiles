#!/bin/bash

session="work"

# Check if session already exists
tmux has-session -t $session &> /dev/null

# Creates new session just if session with same name doesn't already exist
if [ $? != 0 ]; then
  
  # Window 0
  tmux new-session -s $session -n sh -d
  tmux send-keys -t $session:0 'ssh-add ~/.ssh/github' C-m
  
  # Window 1  
  tmux new-window -t $session:1 -n 'dbt'
  tmux send-keys -t $session:1 'cd ~/brm_repos/dbt/primary && nvim' C-m
  tmux split-window -v -t $session:1
  tmux send-keys -t $session:1 'cd ~/brm_repos/dbt/primary' C-m
  tmux send-keys -t $session:1 'clear' C-m
  tmux split-window -h -t $session:1
  tmux send-keys -t $session:1 'cd ~/brm_repos/dbt/primary && lazygit' C-m
  tmux resize-pane -D -t $session:1.%1 -y 65%

  # Window 2  
  tmux new-window -t $session:2 -n 'databricks'
  tmux send-keys -t $session:2 'cd ~/brm_repos/databricks-data-workflows && nvim' C-m
  tmux split-window -v -t $session:2
  tmux send-keys -t $session:2 'cd ~/brm_repos/databricks-data-workflows' C-m
  tmux send-keys -t $session:2 'clear' C-m
  tmux split-window -h -t $session:2
  tmux send-keys -t $session:2 'cd ~/brm_repos/databricks-data-workflows && lazygit' C-m
  tmux resize-pane -D -t $session:2.%1 -y 65%

  # Window 3  
  tmux new-window -t $session:3 -n 'datalake-pipelines'
  tmux send-keys -t $session:3 'cd ~/brm_repos/datalake-pipelines && source .venv/bin/activate && nvim' C-m
  tmux split-window -v -t $session:3
  tmux send-keys -t $session:3 'cd ~/brm_repos/datalake-pipelines && source .venv/bin/activate' C-m
  tmux send-keys -t $session:3 'clear' C-m
  tmux split-window -h -t $session:3
  tmux send-keys -t $session:3 'cd ~/brm_repos/datalake-pipelines && lazygit' C-m
  tmux resize-pane -D -t $session:3.%1 -y 65%

  # Window 4
  #tmux new-window -t $session:4 -n 'obsidian'
  #tmux send-keys -t $session:4 'cd ~/personal/obsidian && gsb' C-m
  #tmux split-window -v -t $session:4
  #tmux send-keys -t $session:4 'cd obsidian_personal && lazygit' C-m

  # Window 5
  tmux new-window -t $session:5 -n 'docker'
  tmux split-window -v -t $session:5

  # Window 8
  tmux new-window -t $session:8 -n 'k8s'

fi

tmux attach-session -t $session:0
