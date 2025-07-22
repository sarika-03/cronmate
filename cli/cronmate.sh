#!/bin/bash

echo "enter your name" -p
read name 

echo "please enter the task you want to perform" -p
read task

echo "please enter the scedule" -p
read schedule 

echo "please enter the command you want to run" -p
read command

json_output=$(printf '{"name": "%s", "task": "%s", "schedule": "%s", "command": "%s"}' "$name" "$task" "$schedule" "command")
echo "$json_output" | jq . > output.json

