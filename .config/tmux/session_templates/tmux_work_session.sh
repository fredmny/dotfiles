#!/bin/bash

session="work"

# Check if session already exists
tmux has-session -t $session &> /dev/null

# Creates new session just if session with same name doesn't already exist
if [ $? != 0 ]; then
	
	# Window 0
	tmux new-session -s $session -n sh -d
	
	# Window 1	
	tmux new-window -t $session:1 -n 'dbt'
  tmux send-keys -t $session:1 'cd dbt && nvim' C-m
	tmux split-window -h -t $session:1
	tmux send-keys -t $session:2 'cd dbt && poetry shell' C-m
	tmux send-keys -t $session:2 'clear' C-m

	# Window 2
	tmux new-window -t $session:2 -n 'obsidian'
	tmux send-keys -t $session:2 'cd obsidian_personal && gsb' C-m

	# Window 3
	tmux new-window -t $session:3 -n 'docker'
	tmux split-window -h -t $session:3

	# Window 4
	tmux new-window -t $session:4 -n 'data-analytics'
  tmux send-keys -t $session:4 'nvim' C-m
	tmux split-window -h -t $session:4
fi

tmux attach-session -t $session:0