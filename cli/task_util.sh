create_task() {
  local reg="^[a-zA-Z0-9@-]+$"

  while true; do 
    read -p "Enter your name: " name
    if [[ -z $name ]]; then
      echo "❌ Name is empty"
    elif [[ $name =~ $reg ]]; then
      break
    else
      echo "❌ Invalid name"
    fi
  done

  while true; do 
    read -p "Enter your task: " task
    if [[ -z $task ]]; then
      echo "❌ Task is empty"
    elif [[ $task =~ $reg ]]; then
      break
    else
      echo "❌ Invalid task"
    fi
  done

  local reg2='^(\*|[0-5]?[0-9]|\*/[1-9][0-9]*)[[:space:]](\*|[01]?[0-9]|2[0-3]|\*/[1-9][0-9]*)[[:space:]](\*|[1-9]|[12][0-9]|3[01]|\*/[1-9][0-9]*)[[:space:]](\*|0?[1-9]|1[0-2]|\*/[1-9][0-9]*)[[:space:]](\*|[0-7]|\*/[1-9][0-9]*)$'

  while true; do 
    read -p "Enter the schedule (cron format): " schedule
    if [[ -z $schedule ]]; then
      echo "❌ Schedule is empty"
    elif [[ "$schedule" =~ $reg2 ]]; then
      break 
    else
      echo "❌ Invalid schedule format"
    fi
  done

  read -p "Enter the command to run: " command
   timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

  local file="./data/tasks.json"

  if [[ ! -f "$file" ]]; then
    echo "[]" > "$file"
  fi

  jq --arg name "$name" \
     --arg task "$task" \
     --arg schedule "$schedule" \
     --arg command "$command" \
     --arg timestamp "$timestamp" \
     '. += [{"name": $name, "task": $task, "schedule": $schedule, "command": $command, "timestamp": $timestamp}]' \
     "$file" > tmp.json && mv tmp.json "$file"

  echo "✅ Task added successfully!"
}

delete_task() {
  local reg="^[a-zA-Z0-9@-]+$"
  local file="./data/tasks.json"
  local del_name

  while true; do 
    read -p "Enter the task name you want to delete: " del_name
    if [[ -z $del_name ]]; then
      echo "❌ Name is empty"
    elif [[ $del_name =~ $reg ]]; then
      break
    else 
      echo "❌ Invalid name format"
    fi
  done

  # Check if name exists in the JSON file
  if jq -e --arg del_name "$del_name" '.[] | select(.name == $del_name)' "$file" > /dev/null; then
    echo "✅ Task with name '$del_name' exists. Deleting..."
    jq --arg del_name "$del_name" 'del(.[] | select(.name == $del_name))' "$file" > tmp.json && mv tmp.json "$file"
    echo "🗑️  Task deleted successfully!"
  else    
    echo "❌ No task with name '$del_name' found. Nothing deleted."
  fi
}

