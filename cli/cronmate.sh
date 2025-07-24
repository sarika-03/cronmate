#!/bin/bash

reg="^[a-zA-Z0-9@-]+$"
while true; do 
read -p "enter your name : " name
   if [[ -z $name ]]; then
   echo "Name is empty"
   elif [[ $name =~ $reg ]]; then
   echo "$name"
   break
   else
   echo "Invalid name"
   fi
done

while true; do 
read -p "enter your task : " task
   if [[ -z $task ]]; then
   echo "task is empty"
   elif [[ $task =~ $reg ]]; then
   echo "$task"
   break
   else
   echo "Invalid task"
   fi
done

reg2='^(\*|[0-5]?[0-9]|\*/[1-9][0-9]*)[[:space:]](\*|[01]?[0-9]|2[0-3]|\*/[1-9][0-9]*)[[:space:]](\*|[1-9]|[12][0-9]|3[01]|\*/[1-9][0-9]*)[[:space:]](\*|0?[1-9]|1[0-2]|\*/[1-9][0-9]*)[[:space:]](\*|[0-7]|\*/[1-9][0-9]*)$'
while true; do 
  read -p "please enter the schedule: " schedule 
  if [[ -z $schedule ]]; then
    echo "schedule is empty"
  elif [[ "$schedule" =~ $reg2 ]]; then
    echo "$schedule"
    break 
  else
    echo "❌ Invalid schedule format"
  fi
done


read -p  "please enter the command you want to run" command
echo $(command)
timestamp="$(date +"%Y-%m-%d %H:%M:%S")"
echo "$timestamp"

if [[ ! -f output.json ]]; then
  echo "[]" > output.json
fi

jq --arg name "$name" \
   --arg task "$task" \
   --arg schedule "$schedule" \
   --arg command "$command" \
   --arg timestamp "$timestamp" \
   '. += [{"name": $name, "task": $task, "schedule": $schedule, "command": $command, "timestamp": $timestamp}]' \
   output.json > tmp.json && mv tmp.json output.json
