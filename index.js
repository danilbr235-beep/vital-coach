#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const DATA_FILE = path.join(__dirname, 'goals.json');

function loadGoals() {
  try {
    const data = fs.readFileSync(DATA_FILE, 'utf-8');
    return JSON.parse(data);
  } catch (err) {
    return [];
  }
}

function saveGoals(goals) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(goals, null, 2));
}

function addGoal(text) {
  const goals = loadGoals();
  const id = Date.now();
  goals.push({ id, text, completed: false });
  saveGoals(goals);
  console.log(`Added goal: ${text}`);
}

function listGoals() {
  const goals = loadGoals();
  if (goals.length === 0) {
    console.log('No goals found.');
    return;
  }
  goals.forEach((goal, index) => {
    const status = goal.completed ? '[x]' : '[ ]';
    console.log(`${index + 1}. ${status} ${goal.text} (id: ${goal.id})`);
  });
}

function completeGoal(id) {
  const goals = loadGoals();
  const goal = goals.find((g) => g.id === Number(id));
  if (!goal) {
    console.log('Goal not found.');
    return;
  }
  goal.completed = true;
  saveGoals(goals);
  console.log(`Completed goal: ${goal.text}`);
}

function deleteGoal(id) {
  const goals = loadGoals();
  const index = goals.findIndex((g) => g.id === Number(id));
  if (index === -1) {
    console.log('Goal not found.');
    return;
  }
  const [removed] = goals.splice(index, 1);
  saveGoals(goals);
  console.log(`Deleted goal: ${removed.text}`);
}

function showHelp() {
  console.log(`Usage:
  soft-cli add <goal description>    Add a new goal
  soft-cli list                      List all goals
  soft-cli complete <id>             Mark a goal as completed
  soft-cli delete <id>               Delete a goal

Examples:
  soft-cli add \"Learn Node.js\"
  soft-cli list`);
}

function main() {
  const args = process.argv.slice(2);
  const command = args[0];
  switch (command) {
    case 'add':
      const description = args.slice(1).join(' ');
      if (!description) {
        console.log('Please provide a goal description.');
      } else {
        addGoal(description);
      }
      break;
    case 'list':
      listGoals();
      break;
    case 'complete':
      completeGoal(args[1]);
      break;
    case 'delete':
      deleteGoal(args[1]);
      break;
    case 'help':
    case '-h':
    case '--help':
    default:
      showHelp();
  }
}

if (require.main === module) {
  main();
}
