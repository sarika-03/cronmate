#!/bin/bash

# Source function definitions once
source ./task_util.sh

echo "HERE IS THE LIST OF OPERATION SELECT ONE"
echo "1. Create a task"
echo "2. View all tasks"
echo "3. Delete a task"
echo "4. Update task command"

read -p "Enter your choice: " choice

case $choice in
  1)
    create_task
    ;;
  2)
    jq . tasks.json
    ;;
  3)
    delete_task
    ;;
  4)
    update_task_command
    ;;
  *)
    echo "❌ Invalid choice"
    ;;
esac

