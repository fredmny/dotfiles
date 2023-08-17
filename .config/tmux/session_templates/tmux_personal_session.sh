#!/bin/bash

session="personal"

# Check if session already exists
tmux has-session -t $session &> /dev/null

# Creates new session just if session with same name doesn't already exist
if [ $? != 0 ]; then
	
	# Window 0
	tmux new-session -s $session -n sh -d
	
	# Window 1	
	tmux new-window -t $session:1 -n 'projects'
	tmux send-keys -t $session:1 'cd projects' C-m
	tmux split-window -h -t $session:1
	tmux send-keys -t $session:1 'vifm .' C-m

	# Window 2
	tmux new-window -t $session:2 -n 'obsidian'
	tmux send-keys -t $session:2 'cd obsidian_personal && gobs' C-m

	# Window 3
	tmux new-window -t $session:3 -n 'docker'
	tmux send-keys -t $session:3 'docker ps' C-m
fi

tmux attach-session -t $session:0
