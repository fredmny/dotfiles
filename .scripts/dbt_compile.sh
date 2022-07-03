#!/usr/bin/env bash

dbtDir="dbt"
dbtFile=$1
compileDir="models/compile"

if [ -z "$1" ]
    then
        echo "No argument supplied. What is the model name?"
        read dbtFile
fi

poetry shell
dbt compile -s $dbtFile
compiledFile="$HOME/$dbtDir/$compileDir/$dbtFile.sql"

# TODO: add confetti from raycast

if [ -f "$compiledFile" ]
    then
        echo "Press enter to copy $compiledFile content to clipboard"
        read input
        # cat $compiledFile > pbcopy
        echo "Model $dbtFile copied to clipboard"
    else
        echo "File $compiledFile not found"
fi

