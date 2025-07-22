#!/bin/bash

read -p "enter your name"
echo $name
read -p "enter tha task name"
echo $task
read -p  "please enter the scedule" 
echo $schedule
read -p  "please enter the command you want to run"
echo $command 

jq -n \
  --arg name "$name" \
  --arg task "$task" \
  --arg schedule "$schedule" \
  --arg command "$command" \
  '{name: $name, task: $task, schedule: $schedule, command: $command}' > output.json

