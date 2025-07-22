#!/bin/bash

read -p "enter your name"
echo $name
read -p "enter tha task name"
echo $task
read -p  "please enter the scedule" 
echo $schedule
read -p  "please enter the command you want to run"
echo $command 

json_output=$(printf '{"name": "%s", "task": "%s", "schedule": "%s", "command": "%s"}' "$name" "$task" "$schedule" "$command")
echo "$json_output" | jq . > output.json

