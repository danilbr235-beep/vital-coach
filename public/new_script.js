// Enhanced client-side script for Soft Goals Manager
// Adds editing and filtering functionality

document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('goal-form');
  const input = document.getElementById('goal-input');
  const dueDateInput = document.getElementById('due-date-input');
  const categoryInput = document.getElementById('category-input');
  const list = document.getElementById('goals-list');

  // Filter UI elements
  const filterCategorySelect = document.getElementById('filter-category');
  const filterOverdueCheckbox = document.getElementById('filter-overdue');
  const filterDueWithinInput = document.getElementById('filter-due-within');
  const applyFiltersBtn = document.getElementById('apply-filters');

  // Local cache of goals to support filtering without extra API calls
  let allGoals = [];

  // Update the category filter options based on current goals
  function updateCategoryFilterOptions() {
    const categories = new Set();
    allGoals.forEach(goal => {
      if (goal.category) categories.add(goal.category);
    });
    // Remove old options except the first ("Все")
    while (filterCategorySelect.options.length > 1) {
      filterCategorySelect.remove(1);
    }
    // Add category options
    categories.forEach(cat => {
      const option = document.createElement('option');
      option.value = cat;
      option.textContent = cat;
      filterCategorySelect.appendChild(option);
    });
  }

  // Determine if a goal matches current filters
  function goalMatchesFilters(goal) {
    // Category filter
    const selectedCategory = filterCategorySelect.value;
    if (selectedCategory && goal.category !== selectedCategory) return false;
    // Overdue filter
    if (filterOverdueCheckbox.checked) {
      if (!goal.dueDate) return false;
      const now = new Date();
      const due = new Date(goal.dueDate);
      if (due >= now) return false;
    }
    // Due within filter
    const dueWithinValue = filterDueWithinInput.value;
    if (dueWithinValue) {
      const days = parseInt(dueWithinValue, 10);
      if (!isNaN(days)) {
        const now = new Date();
        const limit = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);
        if (!goal.dueDate) return false;
        const due = new Date(goal.dueDate);
        if (due > limit) return false;
      }
    }
    return true;
  }

  // Render goals list applying filters
  function renderGoals() {
    list.innerHTML = '';
    allGoals.forEach(goal => {
      if (!goalMatchesFilters(goal)) return;
      const li = document.createElement('li');
      li.textContent = goal.text;

      // Append category and due date
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

      // Actions container
      const actions = document.createElement('div');

      // Complete/Undo button
      const completeBtn = document.createElement('button');
      completeBtn.textContent = goal.completed ? 'Undo' : 'Complete';
      completeBtn.addEventListener('click', async () => {
        await fetch('/api/goals/' + goal.id, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ completed: !goal.completed })
        });
        await fetchGoals();
      });
      actions.appendChild(completeBtn);

      // Edit button
      const editBtn = document.createElement('button');
      editBtn.textContent = 'Edit';
      editBtn.addEventListener('click', async e => {
        e.stopPropagation();
        // Prompt user for new values; use current ones as defaults
        const newText = prompt('Изменить текст цели:', goal.text);
        if (newText === null) return; // cancelled
        const newDueDate = prompt('Изменить дату (YYYY-MM-DD) или оставьте пустым для удаления:', goal.dueDate || '');
        const newCategory = prompt('Изменить категорию или оставьте пустым для удаления:', goal.category || '');
        const payload = {};
        if (newText.trim() !== '' && newText !== goal.text) payload.text = newText.trim();
        if (newDueDate !== null) {
          const trimmedDate = newDueDate.trim();
          if (trimmedDate === '') payload.dueDate = null;
          else payload.dueDate = trimmedDate;
        }
        if (newCategory !== null) {
          const trimmedCat = newCategory.trim();
          if (trimmedCat === '') payload.category = null;
          else payload.category = trimmedCat;
        }
        if (Object.keys(payload).length > 0) {
          await fetch('/api/goals/' + goal.id, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
          });
          await fetchGoals();
        }
      });
      actions.appendChild(editBtn);

      // Delete button
      const deleteBtn = document.createElement('button');
      deleteBtn.textContent = 'Delete';
      deleteBtn.addEventListener('click', async e => {
        e.stopPropagation();
        await fetch('/api/goals/' + goal.id, { method: 'DELETE' });
        await fetchGoals();
      });
      actions.appendChild(deleteBtn);

      li.appendChild(actions);
      list.appendChild(li);
    });
  }

  // Load goals from the backend and store them locally
  async function fetchGoals() {
    const res = await fetch('/api/goals');
    allGoals = await res.json();
    updateCategoryFilterOptions();
    renderGoals();
  }

  // Handle adding a new goal
  form.addEventListener('submit', async e => {
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
    await fetchGoals();
  });

  // Apply filters when clicking the button
  applyFiltersBtn.addEventListener('click', () => {
    renderGoals();
  });

  // Initial load
  fetchGoals();
});