const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'goals.json');

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

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

app.get('/api/goals', (req, res) => {
  res.json(loadGoals());
});

app.post('/api/goals', (req, res) => {
  const { text } = req.body;
  if (!text) {
    return res.status(400).json({ error: 'Text is required' });
  }
  const goals = loadGoals();
  const newGoal = { id: Date.now(), text, completed: false };
  goals.push(newGoal);
  saveGoals(goals);
  res.status(201).json(newGoal);
});

app.put('/api/goals/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { text, completed } = req.body;
  const goals = loadGoals();
  const goal = goals.find(g => g.id === id);
  if (!goal) {
    return res.status(404).json({ error: 'Goal not found' });
  }
  if (text !== undefined) {
    goal.text = text;
  }
  if (completed !== undefined) {
    goal.completed = completed;
  }
  saveGoals(goals);
  res.json(goal);
});

app.delete('/api/goals/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  let goals = loadGoals();
  const index = goals.findIndex(g => g.id === id);
  if (index === -1) {
    return res.status(404).json({ error: 'Goal not found' });
  }
  const deleted = goals.splice(index, 1);
  saveGoals(goals);
  res.json(deleted[0]);
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
