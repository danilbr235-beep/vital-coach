#!/usr/bin/env node

/*
 * Enhanced CLI for the Soft goals manager.
 *
 * Features:
 * - Add goals with optional due date (YYYY-MM-DD) and category.
 * - List goals with optional filtering by category, overdue tasks or due within N days.
 * - Complete a goal by id.
 * - Delete a goal by id.
 * - Edit a goal's text, due date or category.
 *
 * Data is persisted in a JSON file (goals.json) in the same directory.
 */

const fs = require('fs');
const path = require('path');

// Path to the goals storage file. Goals are stored as an array of objects.
const DATA_FILE = path.join(__dirname, 'goals.json');

/**
 * Load goals from the storage file. If the file doesn't exist or can't be
 * parsed, return an empty array.
 *
 * @returns {Array} Array of goal objects.
 */
function loadGoals() {
  try {
    const data = fs.readFileSync(DATA_FILE, 'utf-8');
    return JSON.parse(data);
  } catch (err) {
    return [];
  }
}

/**
 * Save the given array of goals to the storage file.
 *
 * @param {Array} goals Array of goal objects to save.
 */
function saveGoals(goals) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(goals, null, 2));
}

/**
 * Add a new goal.
 *
 * @param {string} description Text of the goal.
 * @param {string|null} dueDate Due date in YYYY-MM-DD format or null.
 * @param {string|null} category Category of the goal or null.
 */
function addGoal(description, dueDate, category) {
  const goals = loadGoals();
  const newGoal = {
    id: Date.now().toString(),
    text: description,
    completed: false,
    dueDate: dueDate || null,
    category: category || null,
  };
  goals.push(newGoal);
  saveGoals(goals);
  console.log(`Added goal: ${description}`);
}

/**
 * Edit an existing goal. Only provided fields are updated.
 *
 * @param {string} id ID of the goal to edit.
 * @param {string|undefined} newText New text for the goal, if provided.
 * @param {string|undefined|null} newDueDate New due date or null to remove due date. If undefined, unchanged.
 * @param {string|undefined|null} newCategory New category or null to remove category. If undefined, unchanged.
 */
function editGoal(id, newText, newDueDate, newCategory) {
  const goals = loadGoals();
  const goal = goals.find(g => g.id === String(id));
  if (!goal) {
    console.log('Goal not found.');
    return;
  }
  if (typeof newText === 'string' && newText.trim() !== '') {
    goal.text = newText;
  }
  if (newDueDate !== undefined) {
    goal.dueDate = newDueDate || null;
  }
  if (newCategory !== undefined) {
    goal.category = newCategory || null;
  }
  saveGoals(goals);
  console.log(`Updated goal ${goal.id}`);
}

/**
 * List goals with optional filtering.
 *
 * @param {Object} opts Options for listing.
 * @param {string|null} opts.category Filter by category (exact match) or null.
 * @param {boolean} opts.overdue If true, only list goals overdue (due date before today).
 * @param {number|null} opts.dueWithin If a number, list goals with due dates within that many days.
 */
function listGoals({ category = null, overdue = false, dueWithin = null } = {}) {
  const goals = loadGoals();
  const now = new Date();

  let filtered = goals;
  if (category) {
    filtered = filtered.filter(g => g.category && g.category.toLowerCase() === category.toLowerCase());
  }
  if (overdue) {
    filtered = filtered.filter(g => g.dueDate && new Date(g.dueDate) < now && !g.completed);
  }
  if (typeof dueWithin === 'number' && !isNaN(dueWithin)) {
    const threshold = new Date(now);
    threshold.setDate(now.getDate() + dueWithin);
    filtered = filtered.filter(g => g.dueDate && new Date(g.dueDate) <= threshold);
  }

  if (filtered.length === 0) {
    console.log('No goals found.');
    return;
  }
  filtered.forEach(goal => {
    const status = goal.completed ? '[x]' : '[ ]';
    const due = goal.dueDate ? ` | Due: ${goal.dueDate}` : '';
    const cat = goal.category ? ` | Category: ${goal.category}` : '';
    console.log(`${goal.id}: ${status} ${goal.text}${due}${cat}`);
  });
}

/**
 * Mark a goal as completed.
 *
 * @param {string} id ID of the goal to mark complete.
 */
function completeGoal(id) {
  const goals = loadGoals();
  const goal = goals.find(g => g.id === String(id));
  if (!goal) {
    console.log('Goal not found.');
    return;
  }
  goal.completed = true;
  saveGoals(goals);
  console.log(`Completed goal: ${goal.text}`);
}

/**
 * Delete a goal.
 *
 * @param {string} id ID of the goal to delete.
 */
function deleteGoal(id) {
  const goals = loadGoals();
  const index = goals.findIndex(g => g.id === String(id));
  if (index === -1) {
    console.log('Goal not found.');
    return;
  }
  const [removed] = goals.splice(index, 1);
  saveGoals(goals);
  console.log(`Deleted goal: ${removed.text}`);
}

/**
 * Display help information for the CLI.
 */
function showHelp() {
  console.log('Soft Goals Manager CLI');
  console.log('');
  console.log('Commands:');
  console.log('  add <description> [--due=YYYY-MM-DD] [--category=Category]');
  console.log('      Add a new goal.');
  console.log('');
  console.log('  list [--category=Category] [--overdue] [--due-within=N]');
  console.log('      List goals. Optionally filter by category, overdue, or due within N days.');
  console.log('');
  console.log('  complete <id>');
  console.log('      Mark a goal as completed.');
  console.log('');
  console.log('  delete <id>');
  console.log('      Delete a goal.');
  console.log('');
  console.log('  edit <id> [--text="New description"] [--due=YYYY-MM-DD|null] [--category=Category|null]');
  console.log('      Edit a goal. Specify only the fields you want to change. Use "null" to remove due date or category.');
  console.log('');
  console.log('  help');
  console.log('      Show this help message.');
}

/**
 * Parse command-line arguments into a structured object.
 *
 * @param {string[]} args Array of CLI arguments after the script name.
 * @returns {Object} Parsed arguments including command and options.
 */
function parseArguments(args) {
  const result = {
    command: null,
    description: '',
    id: null,
    dueDate: undefined,
    category: undefined,
    filterCategory: null,
    overdue: false,
    dueWithin: null,
    newText: undefined,
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
    case 'list': {
      args.slice(1).forEach(arg => {
        if (arg.startsWith('--category=')) {
          result.filterCategory = arg.substring('--category='.length);
        } else if (arg === '--overdue') {
          result.overdue = true;
        } else if (arg.startsWith('--due-within=')) {
          const val = parseInt(arg.substring('--due-within='.length), 10);
          if (!isNaN(val)) {
            result.dueWithin = val;
          }
        }
      });
      break;
    }
    case 'complete':
    case 'delete': {
      result.id = args[1];
      break;
    }
    case 'edit': {
      result.id = args[1];
      const rest = args.slice(2);
      rest.forEach(arg => {
        if (arg.startsWith('--text=')) {
          result.newText = arg.substring('--text='.length);
        } else if (arg.startsWith('--due=')) {
          const val = arg.substring('--due='.length);
          // Interpret literal 'null' as removing the due date
          result.dueDate = val === 'null' ? null : val;
        } else if (arg.startsWith('--category=')) {
          const val = arg.substring('--category='.length);
          result.category = val === 'null' ? null : val;
        }
      });
      break;
    }
    default:
      break;
  }
  return result;
}

/**
 * Main entry point. Parses arguments and invokes the appropriate command.
 */
function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    showHelp();
    return;
  }
  const parsed = parseArguments(args);
  const {
    command,
    description,
    id,
    dueDate,
    category,
    filterCategory,
    overdue,
    dueWithin,
    newText,
  } = parsed;
  switch (command) {
    case 'add':
      if (!description) {
        console.log('Please provide a goal description.');
      } else {
        addGoal(description, dueDate, category);
      }
      break;
    case 'list':
      listGoals({ category: filterCategory, overdue, dueWithin });
      break;
    case 'complete':
      if (!id) {
        console.log('Please specify the goal ID to complete.');
      } else {
        completeGoal(id);
      }
      break;
    case 'delete':
      if (!id) {
        console.log('Please specify the goal ID to delete.');
      } else {
        deleteGoal(id);
      }
      break;
    case 'edit':
      if (!id) {
        console.log('Please specify the goal ID to edit.');
      } else {
        editGoal(id, newText, dueDate, category);
      }
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
