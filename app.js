const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'goals.json');

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Load goals from JSON file
function loadGoals() {
  try {
    const data = fs.readFileSync(DATA_FILE, 'utf-8');
    return JSON.parse(data);
  } catch (err) {
    return [];
  }
}

// Save goals to JSON file
function saveGoals(goals) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(goals, null, 2));
}

// Get all goals
app.get('/api/goals', (req, res) => {
  res.json(loadGoals());
});

// Create a new goal with optional dueDate and category
app.post('/api/goals', (req, res) => {
  const { text, dueDate, category } = req.body;
  if (!text) {
    return res.status(400).json({ error: 'Text is required' });
  }
  const goals = loadGoals();
  const newGoal = {
    id: Date.now().toString(),
    text,
    dueDate: dueDate || null,
    category: category || null,
    completed: false
  };
  goals.push(newGoal);
  saveGoals(goals);
  res.status(201).json(newGoal);
});

// Update an existing goal by id (text, completed, dueDate, category)
app.put('/api/goals/:id', (req, res) => {
  const { id } = req.params;
  const { text, completed, dueDate, category } = req.body;
  const goals = loadGoals();
  const goalIndex = goals.findIndex((goal) => goal.id === id);
  if (goalIndex === -1) {
    return res.status(404).json({ error: 'Goal not found' });
  }
  if (text !== undefined) {
    goals[goalIndex].text = text;
  }
  if (completed !== undefined) {
    goals[goalIndex].completed = completed;
  }
  if (dueDate !== undefined) {
    goals[goalIndex].dueDate = dueDate;
  }
  if (category !== undefined) {
    goals[goalIndex].category = category;
  }
  saveGoals(goals);
  res.json(goals[goalIndex]);
});

// Delete a goal by id
app.delete('/api/goals/:id', (req, res) => {
  const { id } = req.params;
  const goals = loadGoals();
  const index = goals.findIndex((g) => g.id === id);
  if (index === -1) {
    return res.status(404).json({ error: 'Goal not found' });
  }
  goals.splice(index, 1);
  saveGoals(goals);
  res.status(204).end();
});

// Start the server
app.listen(PORT, () => {
  console.log('Server running at http://localhost:' + PORT);
});
