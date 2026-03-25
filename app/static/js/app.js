// ── API Base URL ───────────────────────────────────────────
// Empty string means same server as frontend
// FastAPI serves both frontend AND API! 🎯
const API_URL = '/employees';

// ── Global State ───────────────────────────────────────────
let allEmployees = [];      // Store all employees
let deleteEmployeeId = null; // Store ID for deletion

// ── Avatar Colours ─────────────────────────────────────────
const avatarColors = [
  'avatar-blue',
  'avatar-green',
  'avatar-purple',
  'avatar-orange'
];

// ══════════════════════════════════════════════════════════
// SECTION 1: FETCH & DISPLAY EMPLOYEES
// ══════════════════════════════════════════════════════════

// Fetch all employees from FastAPI
async function fetchEmployees() {
  try {
    showLoading();
    const response = await fetch(`${API_URL}/`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const employees = await response.json();
    allEmployees = employees;

    updateStats(employees);
    renderTable(employees);
    populateDeptFilter(employees);

  } catch (error) {
    showError('Failed to load employees. Please try again.');
    console.error('Error fetching employees:', error);
  }
}

// Render employees in table
function renderTable(employees) {
  const tbody = document.getElementById('employee-tbody');

  if (employees.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="5">
          <div class="empty-state">
            <i class="bi bi-people"></i>
            <p>No employees found</p>
            <button class="btn btn-primary btn-sm"
                    onclick="openAddModal()">
              Add First Employee
            </button>
          </div>
        </td>
      </tr>`;
    return;
  }

  tbody.innerHTML = employees.map((emp, index) => `
    <tr>
      <td data-label="Name">
        <div class="d-flex align-items-center">
          <div class="avatar ${getAvatarColor(index)}">
            ${getInitials(emp.first_name, emp.last_name)}
          </div>
          <span class="fw-500">
            ${emp.first_name} ${emp.last_name}
          </span>
        </div>
      </td>
      <td data-label="Email" class="text-muted">
        ${emp.email}
      </td>
      <td data-label="Department">
        <span class="dept-badge">${emp.department}</span>
      </td>
      <td data-label="Role">${emp.role}</td>
      <td data-label="Actions">
        <div class="d-flex gap-2">
          <button class="btn btn-outline-primary btn-action"
                  onclick="openEditModal(${emp.id})">
            <i class="bi bi-pencil me-1"></i>Edit
          </button>
          <button class="btn btn-outline-danger btn-action"
                  onclick="openDeleteModal(${emp.id},
                  '${emp.first_name} ${emp.last_name}')">
            <i class="bi bi-trash me-1"></i>Delete
          </button>
        </div>
      </td>
    </tr>
  `).join('');
}

// ══════════════════════════════════════════════════════════
// SECTION 2: STATS
// ══════════════════════════════════════════════════════════

function updateStats(employees) {
  // Total employees
  document.getElementById('total-employees')
    .textContent = employees.length;

  // Unique departments
  const departments = [...new Set(
    employees.map(e => e.department)
  )];
  document.getElementById('total-departments')
    .textContent = departments.length;

  // Latest employee
  if (employees.length > 0) {
    const latest = employees[employees.length - 1];
    document.getElementById('latest-employee')
      .textContent = `${latest.first_name} ${latest.last_name}`;
  }

  // API Status
  document.getElementById('api-status')
    .textContent = 'Healthy';
}

// ══════════════════════════════════════════════════════════
// SECTION 3: ADD EMPLOYEE
// ══════════════════════════════════════════════════════════

function openAddModal() {
  // Clear form
  document.getElementById('employee-id').value = '';
  document.getElementById('first-name').value = '';
  document.getElementById('last-name').value = '';
  document.getElementById('email').value = '';
  document.getElementById('department').value = '';
  document.getElementById('role').value = '';

  // Set modal title
  document.getElementById('modal-title')
    .textContent = 'Add Employee';

  // Show modal
  const modal = new bootstrap.Modal(
    document.getElementById('employeeModal')
  );
  modal.show();
}

// ══════════════════════════════════════════════════════════
// SECTION 4: EDIT EMPLOYEE
// ══════════════════════════════════════════════════════════

function openEditModal(id) {
  // Find employee from our stored list
  const emp = allEmployees.find(e => e.id === id);
  if (!emp) return;

  // Fill form with existing data
  document.getElementById('employee-id').value = emp.id;
  document.getElementById('first-name').value = emp.first_name;
  document.getElementById('last-name').value = emp.last_name;
  document.getElementById('email').value = emp.email;
  document.getElementById('department').value = emp.department;
  document.getElementById('role').value = emp.role;

  // Set modal title
  document.getElementById('modal-title')
    .textContent = 'Edit Employee';

  // Show modal
  const modal = new bootstrap.Modal(
    document.getElementById('employeeModal')
  );
  modal.show();
}

// ══════════════════════════════════════════════════════════
// SECTION 5: SAVE EMPLOYEE (ADD or EDIT)
// ══════════════════════════════════════════════════════════

async function saveEmployee() {
  // Get form values
  const id = document.getElementById('employee-id').value;
  const firstName = document.getElementById('first-name').value.trim();
  const lastName = document.getElementById('last-name').value.trim();
  const email = document.getElementById('email').value.trim();
  const department = document.getElementById('department').value.trim();
  const role = document.getElementById('role').value.trim();

  // Validate — all fields required!
  if (!firstName || !lastName || !email ||
      !department || !role) {
    showToast('Error', 'Please fill in all fields!', 'danger');
    return;
  }

  // Build request body
  const body = {
    first_name: firstName,
    last_name: lastName,
    email: email,
    department: department,
    role: role
  };

  try {
    let response;

    if (id) {
      // UPDATE existing employee — PUT request
      response = await fetch(`${API_URL}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
    } else {
      // CREATE new employee — POST request
      response = await fetch(`${API_URL}/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
    }

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Something went wrong');
    }

    // Close modal
    bootstrap.Modal.getInstance(
      document.getElementById('employeeModal')
    ).hide();

    // Show success toast
    const action = id ? 'updated' : 'added';
    showToast(
      'Success',
      `Employee ${action} successfully!`,
      'success'
    );

    // Refresh table
    await fetchEmployees();

  } catch (error) {
    showToast('Error', error.message, 'danger');
    console.error('Error saving employee:', error);
  }
}

// ══════════════════════════════════════════════════════════
// SECTION 6: DELETE EMPLOYEE
// ══════════════════════════════════════════════════════════

function openDeleteModal(id, name) {
  deleteEmployeeId = id;
  document.getElementById('delete-name').textContent = name;

  const modal = new bootstrap.Modal(
    document.getElementById('deleteModal')
  );
  modal.show();
}

async function confirmDelete() {
  if (!deleteEmployeeId) return;

  try {
    const response = await fetch(
      `${API_URL}/${deleteEmployeeId}`,
      { method: 'DELETE' }
    );

    if (!response.ok) {
      throw new Error('Failed to delete employee');
    }

    // Close modal
    bootstrap.Modal.getInstance(
      document.getElementById('deleteModal')
    ).hide();

    // Show success toast
    showToast('Success', 'Employee deleted!', 'success');

    // Refresh table
    await fetchEmployees();

  } catch (error) {
    showToast('Error', error.message, 'danger');
    console.error('Error deleting employee:', error);
  }
}

// ══════════════════════════════════════════════════════════
// SECTION 7: SEARCH & FILTER
// ══════════════════════════════════════════════════════════

function filterEmployees() {
  const searchTerm = document.getElementById('search-input')
    .value.toLowerCase();
  const deptFilter = document.getElementById('dept-filter')
    .value.toLowerCase();

  const filtered = allEmployees.filter(emp => {
    const matchesSearch =
      emp.first_name.toLowerCase().includes(searchTerm) ||
      emp.last_name.toLowerCase().includes(searchTerm) ||
      emp.email.toLowerCase().includes(searchTerm) ||
      emp.role.toLowerCase().includes(searchTerm) ||
      emp.department.toLowerCase().includes(searchTerm);

    const matchesDept = !deptFilter ||
      emp.department.toLowerCase() === deptFilter;

    return matchesSearch && matchesDept;
  });

  renderTable(filtered);
}

function populateDeptFilter(employees) {
  const departments = [...new Set(
    employees.map(e => e.department)
  )];
  const select = document.getElementById('dept-filter');

  // Keep "All Departments" option
  select.innerHTML = '<option value="">All Departments</option>';

  departments.forEach(dept => {
    const option = document.createElement('option');
    option.value = dept;
    option.textContent = dept;
    select.appendChild(option);
  });
}

// ══════════════════════════════════════════════════════════
// SECTION 8: HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════

// Get initials from name
function getInitials(firstName, lastName) {
  return `${firstName[0]}${lastName[0]}`.toUpperCase();
}

// Get avatar colour based on index
function getAvatarColor(index) {
  return avatarColors[index % avatarColors.length];
}

// Show loading spinner in table
function showLoading() {
  document.getElementById('employee-tbody').innerHTML = `
    <tr>
      <td colspan="5" class="text-center py-4 text-muted">
        <div class="spinner-border spinner-border-sm me-2">
        </div>
        Loading employees...
      </td>
    </tr>`;
}

// Show error message in table
function showError(message) {
  document.getElementById('employee-tbody').innerHTML = `
    <tr>
      <td colspan="5" class="text-center py-4 text-danger">
        <i class="bi bi-exclamation-circle me-2"></i>
        ${message}
      </td>
    </tr>`;
}

// Show toast notification
function showToast(title, message, type = 'success') {
  const toast = document.getElementById('toast');
  const toastTitle = document.getElementById('toast-title');
  const toastBody = document.getElementById('toast-body');

  // Set content
  toastTitle.textContent = title;
  toastBody.textContent = message;

  // Set colour based on type
  toast.className = `toast border-${type}`;
  toastTitle.className = `me-auto text-${type}`;

  // Show toast
  const bsToast = new bootstrap.Toast(toast, { delay: 3000 });
  bsToast.show();
}

// ══════════════════════════════════════════════════════════
// SECTION 9: EVENT LISTENERS
// ══════════════════════════════════════════════════════════

// Search input — filter as user types
document.getElementById('search-input')
  .addEventListener('input', filterEmployees);

// Department filter — filter on change
document.getElementById('dept-filter')
  .addEventListener('change', filterEmployees);

// ══════════════════════════════════════════════════════════
// SECTION 10: INITIALISE
// ══════════════════════════════════════════════════════════

// Load employees when page loads
document.addEventListener('DOMContentLoaded', fetchEmployees);