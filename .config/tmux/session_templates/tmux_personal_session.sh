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
	tmux new-window -t $session:2 -n 'mds project'
	tmux send-keys -t $session:2 'cd projects/meltano_mds/finance_mds' C-m
	tmux send-keys -t $session:2 'nvim' C-m
	tmux split-window -h -t $session:2
	tmux send-keys -t $session:2 'poetry shell' C-m

	# Window 3
	tmux new-window -t $session:3 -n 'obsidian'
	tmux send-keys -t $session:3 'cd obsidian_personal && gobs' C-m

	# Window 4
	tmux new-window -t $session:4 -n 'docker'
	tmux send-keys -t $session:4 'cd projects/obsidian_personal_sync && docker ps' C-m

	# Window 5	
	tmux new-window -t $session:5 -n 'flutter'
	tmux send-keys -t $session:5 'cd /home/prophet/projects/courses/fireship_flutter/quizapp' C-m
	tmux send-keys -t $session:5 'nvim' C-m
	tmux split-window -h -t $session:5
	tmux send-keys -t $session:5 'cd /home/prophet/projects/courses/fireship_flutter/quizapp' C-m
fi

tmux attach-session -t $session:0
