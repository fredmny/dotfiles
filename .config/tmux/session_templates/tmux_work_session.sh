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
  tmux send-keys -t $session:1 'cd dbt && nvim' C-m
  tmux split-window -v -t $session:1
  tmux send-keys -t $session:1 'cd dbt && poetry shell' C-m
  tmux send-keys -t $session:1 'clear' C-m
  tmux split-window -h -t $session:1
  tmux send-keys -t $session:1 'cd dbt && lazygit' C-m
  tmux resize-pane -D -t $session:1.%1 -y 65%

  # Window 2  
  tmux new-window -t $session:2 -n 'dbt 2'
  tmux send-keys -t $session:2 'cd trustly_repos/dbt_secondary && nvim' C-m
  tmux split-window -v -t $session:2
  tmux send-keys -t $session:2 'cd trustly_repos/dbt_secondary && poetry shell' C-m
  tmux send-keys -t $session:2 'clear' C-m
  tmux split-window -h -t $session:2
  tmux send-keys -t $session:2 'cd trustly_repos/dbt_secondary && lazygit' C-m
  tmux resize-pane -D -t $session:2.%4 -y 65%

  # Window 3  
  tmux new-window -t $session:3 -n 'foundation'
  tmux send-keys -t $session:3 'cd trustly_repos/dbt_foundation && nvim' C-m
  tmux split-window -v -t $session:3
  tmux send-keys -t $session:3 'cd trustly_repos/dbt_foundation && poetry shell' C-m
  tmux send-keys -t $session:3 'clear' C-m
  tmux split-window -h -t $session:3
  tmux send-keys -t $session:3 'cd trustly_repos/dbt_foundation && lazygit' C-m
  tmux resize-pane -D -t $session:3.%7 -y 65%

  # Window 4
  tmux new-window -t $session:4 -n 'obsidian'
  tmux send-keys -t $session:4 'cd obsidian_personal && gsb' C-m
  tmux split-window -v -t $session:4
  tmux send-keys -t $session:4 'cd obsidian_personal && lazygit' C-m

  # Window 5
  tmux new-window -t $session:5 -n 'docker'
  tmux split-window -v -t $session:5

  # Window 6
  tmux new-window -t $session:6 -n 'data-analytics'
  tmux send-keys -t $session:6 'cd trustly_repos/data-analytics && nvim' C-m
  tmux split-window -v -t $session:6
  tmux send-keys -t $session:6 'cd trustly_repos/data-analytics' C-m
  tmux send-keys -t $session:6 'clear' C-m
  tmux split-window -h -t $session:6
  tmux send-keys -t $session:6 'cd trustly_repos/data-analytics && lazygit' C-m
  tmux resize-pane -D -t $session:6.%14 -y 65%

  # Window 7
  tmux new-window -t $session:7 -n 'data-engineering'
  tmux send-keys -t $session:7 'cd trustly_repos/data-engineering && nvim' C-m
  tmux split-window -v -t $session:7
  tmux send-keys -t $session:7 'cd trustly_repos/data-engineering' C-m
  tmux send-keys -t $session:7 'clear' C-m
  tmux split-window -h -t $session:7
  tmux send-keys -t $session:7 'cd trustly_repos/data-engineering && lazygit' C-m
  tmux resize-pane -D -t $session:7.%17 -y 65%

fi

tmux attach-session -t $session:0
