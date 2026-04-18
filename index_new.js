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

function addGoal(description, dueDate, category) {
  const goals = loadGoals();
  const newGoal = {
    id: Date.now(),
    text: description,
    completed: false,
    dueDate: dueDate || null,
    category: category || null,
  };
  goals.push(newGoal);
  saveGoals(goals);
  console.log(`Added goal: ${description}`);
}

function listGoals() {
  const goals = loadGoals();
  if (goals.length === 0) {
    console.log('No goals found.');
    return;
  }
  goals.forEach(goal => {
    const status = goal.completed ? '[x]' : '[ ]';
    const due = goal.dueDate ? ` | Due: ${goal.dueDate}` : '';
    const cat = goal.category ? ` | Category: ${goal.category}` : '';
    console.log(`${goal.id}: ${status} ${goal.text}${due}${cat}`);
  });
}

function completeGoal(id) {
  const goals = loadGoals();
  const goal = goals.find(g => String(g.id) === String(id));
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
  const index = goals.findIndex(g => String(g.id) === String(id));
  if (index === -1) {
    console.log('Goal not found.');
    return;
  }
  const [removed] = goals.splice(index, 1);
  saveGoals(goals);
  console.log(`Deleted goal: ${removed.text}`);
}

function showHelp() {
  console.log('Usage:');
  console.log('  soft-cli add <goal description> [--due=YYYY-MM-DD] [--category=Category]   Add a new goal');
  console.log('  soft-cli list                                                     List all goals');
  console.log('  soft-cli complete <id>                                            Mark a goal as completed');
  console.log('  soft-cli delete <id>                                              Delete a goal');
  console.log('  soft-cli help                                                     Show this help message');
}

function parseArguments(args) {
  const result = {
    command: null,
    description: '',
    dueDate: null,
    category: null,
    id: null,
  };
  if (args.length === 0) {
    return result;
  }
  result.command = args[0];
  switch (result.command) {
    case 'add': {
      const descriptionParts = [];
      args.slice(1).forEach(arg => {
        if (arg.startsWith('--due=')) {
          result.dueDate = arg.substring('--due='.length);
        } else if (arg.startsWith('--category=')) {
          result.category = arg.substring('--category='.length);
        } else {
          descriptionParts.push(arg);
        }
      });
      result.description = descriptionParts.join(' ');
      break;
    }
    case 'complete':
    case 'delete': {
      result.id = args[1];
      break;
    }
    default:
      break;
  }
  return result;
}

function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    showHelp();
    return;
  }
  const { command, description, dueDate, category, id } = parseArguments(args);
  switch (command) {
    case 'add':
      if (!description) {
        console.log('Please provide a goal description.');
      } else {
        addGoal(description, dueDate, category);
      }
      break;
    case 'list':
      listGoals();
      break;
    case 'complete':
      completeGoal(id);
      break;
    case 'delete':
      deleteGoal(id);
      break;
    case 'help':
    case '--help':
    case '-h':
      showHelp();
      break;
    default:
      console.log(`Unknown command: ${command}`);
      showHelp();
  }
}

if (require.main === module) {
  main();
}
