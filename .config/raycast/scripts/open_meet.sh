#!/bin/bash

# Raycast Script Command Template
#
# Duplicate this file and remove ".template." from the filename to get started.
# See full documentation here: https://github.com/raycast/script-commands
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Google Meet
# @raycast.mode fullOutput
# @raycast.packageName Raycast Scripts
#
# Optional parameters:
# @raycast.icon 🤖
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false
#
# Documentation:
# @raycast.description Write a nice and descriptive summary about your script command here 
# @raycast.author Your name
# @raycast.authorURL An URL for one of your social medias

open "raycast://extensions/the-browser-company/arc/search?fallbackText=meet&launchType=userInitiated"
