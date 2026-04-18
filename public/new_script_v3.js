// Расширенный клиентский скрипт: редактирование, фильтры, уведомления

document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('goal-form');
  const input = document.getElementById('goal-input');
  const dueDateInput = document.getElementById('due-date-input');
  const categoryInput = document.getElementById('category-input');
  const list = document.getElementById('goals-list');

  // Элементы фильтров
  const filterCategorySelect = document.getElementById('filter-category');
  const filterOverdueCheckbox = document.getElementById('filter-overdue');
  const filterDueWithinInput = document.getElementById('filter-due-within');
  const applyFiltersBtn = document.getElementById('apply-filters');

  // Контейнер для уведомлений
  const notificationsContainer = document.getElementById('notifications');

  // Локальное кэширование задач
  let allGoals = [];

  // Функция создания уведомлений
  function showNotification(message, type = 'success') {
    const notif = document.createElement('div');
    notif.className = `notification ${type}`;
    notif.textContent = message;
    notificationsContainer.appendChild(notif);
    setTimeout(() => {
      notif.remove();
    }, 3000);
  }

  // Заполнение фильтра по категориям
  function updateCategoryFilterOptions() {
    const categories = new Set();
    allGoals.forEach(goal => {
      if (goal.category) categories.add(goal.category);
    });
    while (filterCategorySelect.options.length > 1) {
      filterCategorySelect.remove(1);
    }
    categories.forEach(cat => {
      const option = document.createElement('option');
      option.value = cat;
      option.textContent = cat;
      filterCategorySelect.appendChild(option);
    });
  }

  // Проверка совпадения задачи с активными фильтрами
  function goalMatchesFilters(goal) {
    const selectedCategory = filterCategorySelect.value;
    if (selectedCategory && goal.category !== selectedCategory) return false;
    if (filterOverdueCheckbox.checked) {
      if (!goal.dueDate) return false;
      const now = new Date();
      const due = new Date(goal.dueDate);
      if (due >= now) return false;
    }
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

  // Отрисовка списка задач с учётом фильтров
  function renderGoals() {
    list.innerHTML = '';
    const now = new Date();
    allGoals.forEach(goal => {
      if (!goalMatchesFilters(goal)) return;

      const li = document.createElement('li');

      // Текст цели
      const textSpan = document.createElement('span');
      textSpan.textContent = goal.text;
      li.appendChild(textSpan);

      // Категория
      if (goal.category) {
        const categorySpan = document.createElement('span');
        categorySpan.className = 'meta';
        categorySpan.textContent = ` (${goal.category})`;
        li.appendChild(categorySpan);
      }

      // Дата выполнения
      if (goal.dueDate) {
        const dueSpan = document.createElement('span');
        const date = new Date(goal.dueDate);
        dueSpan.className = 'meta';
        dueSpan.textContent = ` [до: ${date.toLocaleDateString()}]`;
        li.appendChild(dueSpan);
      }

      // Статусы
      if (goal.completed) {
        li.classList.add('completed');
      } else if (goal.dueDate && new Date(goal.dueDate) < now) {
        li.classList.add('overdue');
      }

      // Блок кнопок
      const actions = document.createElement('div');
      actions.className = 'actions';

      // Кнопка завершения/отмены
      const completeBtn = document.createElement('button');
      completeBtn.innerHTML = goal.completed
        ? '<i class="fas fa-undo"></i> Отменить'
        : '<i class="fas fa-check"></i> Завершить';
      completeBtn.addEventListener('click', async () => {
        const res = await fetch('/api/goals/' + goal.id, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ completed: !goal.completed })
        });
        if (res.ok) showNotification(goal.completed ? 'Цель восстановлена' : 'Цель выполнена');
        await fetchGoals();
      });
      actions.appendChild(completeBtn);

      // Кнопка редактирования
      const editBtn = document.createElement('button');
      editBtn.classList.add('edit');
      editBtn.innerHTML = '<i class="fas fa-edit"></i> Изменить';
      editBtn.addEventListener('click', async e => {
        e.stopPropagation();
        const newText = prompt('Изменить текст цели:', goal.text);
        if (newText === null) return;
        const newDueDate = prompt(
          'Изменить дату (YYYY-MM-DD) или оставьте пустым для удаления:',
          goal.dueDate || ''
        );
        const newCategory = prompt(
          'Изменить категорию или оставьте пустым для удаления:',
          goal.category || ''
        );
        const payload = {};
        if (newText.trim() !== '' && newText !== goal.text) payload.text = newText.trim();
        if (newDueDate !== null) {
          const trimmedDate = newDueDate.trim();
          payload.dueDate = trimmedDate === '' ? null : trimmedDate;
        }
        if (newCategory !== null) {
          const trimmedCat = newCategory.trim();
          payload.category = trimmedCat === '' ? null : trimmedCat;
        }
        if (Object.keys(payload).length > 0) {
          const res = await fetch('/api/goals/' + goal.id, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
          });
          if (res.ok) showNotification('Цель изменена');
          await fetchGoals();
        }
      });
      actions.appendChild(editBtn);

      // Кнопка удаления
      const deleteBtn = document.createElement('button');
      deleteBtn.classList.add('delete');
      deleteBtn.innerHTML = '<i class="fas fa-trash"></i> Удалить';
      deleteBtn.addEventListener('click', async e => {
        e.stopPropagation();
        const res = await fetch('/api/goals/' + goal.id, { method: 'DELETE' });
        if (res.ok) showNotification('Цель удалена', 'error');
        await fetchGoals();
      });
      actions.appendChild(deleteBtn);

      li.appendChild(actions);
      list.appendChild(li);
    });
  }

  // Загрузка задач с сервера
  async function fetchGoals() {
    const res = await fetch('/api/goals');
    allGoals = await res.json();
    updateCategoryFilterOptions();
    renderGoals();
  }

  // Добавление новой цели
  form.addEventListener('submit', async e => {
    e.preventDefault();
    const text = input.value.trim();
    const dueDate = dueDateInput.value;
    const category = categoryInput.value.trim();
    if (!text) {
      alert('Введите цель');
      return;
    }
    const res = await fetch('/api/goals', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text, dueDate: dueDate || null, category })
    });
    if (res.ok) showNotification('Цель добавлена');
    input.value = '';
    dueDateInput.value = '';
    categoryInput.value = '';
    await fetchGoals();
  });

  // Применение фильтров
  applyFiltersBtn.addEventListener('click', () => {
    renderGoals();
  });

  // Стартовая загрузка
  fetchGoals();
});