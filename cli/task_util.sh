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
  echo $(command)
   timestamp="$(date +"%Y-%m-%d %H:%M:%S")"
   
   file=tasks.json


  if [[ ! -f "$file" ]]; then
    echo "[]" > "$file"
  fi

# 👇 DUPLICATE CHECK GOES HERE
if jq -e --arg name "$name" '.[] | select(.name == $name)' "$file" > /dev/null; then
  echo "❌ A task with the name '$name' already exists. Choose a different name."
  return
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
  local file=tasks.json
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

list_tasks() {
  local file=tasks.json
  if [[ ! -f "$file" || $(jq length "$file") -eq 0 ]]; then
    echo "📂 No tasks found."
    return
  fi

  echo "📋 Task List:"
  jq -r '.[] | "👤 \(.name)\n📝 \(.task)\n⏰ \(.schedule)\n💻 \(.command)\n🕒 Created At: \(.timestamp)\n"' "$file"
}

update_task_command() {
  local file=tasks.json
  local name new_command

  read -p "Enter the task name to update command: " name
  if ! jq -e --arg name "$name" '.[] | select(.name == $name)' "$file" > /dev/null; then
    echo "❌ Task with name '$name' does not exist."
    return
  fi

  read -p "Enter the new command: " new_command
  timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

  jq --arg name "$name" --arg new_command "$new_command" --arg timestamp "$timestamp" \
     'map(if .name == $name then .command = $new_command | .timestamp = $timestamp else . end)' \
     "$file" > tmp.json && mv tmp.json "$file"

  echo "🔄 Command updated successfully for task '$name'!"
}

update_task_schedule() {
  local file=tasks.json
  local name new_schedule
  local reg2='^(\*|[0-5]?[0-9]|\*/[1-9][0-9]*)[[:space:]](\*|[01]?[0-9]|2[0-3]|\*/[1-9][0-9]*)[[:space:]](\*|[1-9]|[12][0-9]|3[01]|\*/[1-9][0-9]*)[[:space:]](\*|0?[1-9]|1[0-2]|\*/[1-9][0-9]*)[[:space:]](\*|[0-7]|\*/[1-9][0-9]*)$'

  read -p "Enter the task name to update schedule: " name
  if ! jq -e --arg name "$name" '.[] | select(.name == $name)' "$file" > /dev/null; then
    echo "❌ Task with name '$name' does not exist."
    return
  fi

  while true; do 
    read -p "Enter new schedule (cron format): " new_schedule
    if [[ "$new_schedule" =~ $reg2 ]]; then
      break
    else
      echo "❌ Invalid cron format. Try again."
    fi
  done

  jq --arg name "$name" --arg new_schedule "$new_schedule" \
     'map(if .name == $name then .schedule = $new_schedule else . end)' "$file" > tmp.json && mv tmp.json "$file"

  echo "📅 Schedule updated successfully for task '$name'."
}

run_task_now() {
  local file=tasks.json
  local name command

  read -p "Enter the task name to run: " name
  command=$(jq -r --arg name "$name" '.[] | select(.name == $name) | .command' "$file")

  if [[ -z "$command" || "$command" == "null" ]]; then
    echo "❌ Task not found or has no command."
    return
  fi

  echo "▶️ Running command for task '$name':"
  echo "👉 $command"
  eval "$command"
}
