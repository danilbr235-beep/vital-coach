document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('goal-form');
  const input = document.getElementById('goal-input');
  const dueDateInput = document.getElementById('due-date-input');
  const categoryInput = document.getElementById('category-input');
  const list = document.getElementById('goals-list');

  async function fetchGoals() {
    const res = await fetch('/api/goals');
    const goals = await res.json();
    list.innerHTML = '';
    goals.forEach((goal) => {
      const li = document.createElement('li');
      li.textContent = goal.text;

      // Append category and due date info
      if (goal.category) {
        const categorySpan = document.createElement('span');
        categorySpan.textContent = ' (' + goal.category + ')';
        li.appendChild(categorySpan);
      }
      if (goal.dueDate) {
        const dueDateSpan = document.createElement('span');
        const date = new Date(goal.dueDate);
        dueDateSpan.textContent = ' [Due: ' + date.toLocaleDateString() + ']';
        li.appendChild(dueDateSpan);
      }

      if (goal.completed) {
        li.classList.add('completed');
      }

      // Create actions container and buttons
      const actions = document.createElement('div');
      const completeBtn = document.createElement('button');
      completeBtn.textContent = goal.completed ? 'Undo' : 'Complete';
      completeBtn.addEventListener('click', async () => {
        await fetch('/api/goals/' + goal.id, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ completed: !goal.completed })
        });
        fetchGoals();
      });

      const deleteBtn = document.createElement('button');
      deleteBtn.textContent = 'Delete';
      deleteBtn.addEventListener('click', async (e) => {
        e.stopPropagation();
        await fetch('/api/goals/' + goal.id, { method: 'DELETE' });
        fetchGoals();
      });

      actions.appendChild(completeBtn);
      actions.appendChild(deleteBtn);
      li.appendChild(actions);
      list.appendChild(li);
    });
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const text = input.value.trim();
    const dueDate = dueDateInput.value;
    const category = categoryInput.value.trim();
    if (!text) {
      alert('Введите цель');
      return;
    }
    await fetch('/api/goals', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text, dueDate: dueDate || null, category })
    });
    input.value = '';
    dueDateInput.value = '';
    categoryInput.value = '';
    fetchGoals();
  });

  fetchGoals();
});
