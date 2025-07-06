<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    com.expensetracker.model.User user = (com.expensetracker.model.User) session.getAttribute("user");
    String name = user.getName();
    String initials = name.length() >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
%>

<html>
<head>
    <title>Add Expense - Daily Expense Tracker</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #4361ee;
            --secondary: #3f37c9;
            --success: #4cc9f0;
            --warning: #f72585;
            --light: #f8f9fa;
            --dark: #212529;
            --gray: #6c757d;
            --light-gray: #e9ecef;
            --border: #dee2e6;
            --card-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f5f7fb;
            color: var(--dark);
            line-height: 1.6;
        }

        .dashboard-container {
            display: grid;
            grid-template-columns: 260px 1fr;
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            background: linear-gradient(180deg, var(--primary), var(--secondary));
            color: white;
            padding: 20px 0;
            position: fixed;
            width: 260px;
            height: 100%;
            overflow-y: auto;
            box-shadow: var(--card-shadow);
            z-index: 100;
        }

        .brand {
            padding: 0 20px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 20px;
        }

        .brand h1 {
            font-size: 1.5rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .brand i {
            color: var(--success);
        }

        .nav-menu {
            padding: 0 15px;
        }

        .nav-item {
            margin-bottom: 5px;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .nav-item:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        .nav-item.active {
            background: rgba(255, 255, 255, 0.2);
        }

        .nav-link {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            color: white;
            text-decoration: none;
            font-weight: 500;
            gap: 12px;
        }

        .nav-link i {
            width: 24px;
            text-align: center;
        }

        /* Main Content */
        .main-content {
            grid-column: 2;
            padding: 20px 30px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), var(--success));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 1.2rem;
        }

        .user-details h2 {
            font-size: 1.3rem;
            margin-bottom: 5px;
        }

        .user-details p {
            color: var(--gray);
            font-size: 0.9rem;
        }

        .logout-btn {
            background: none;
            border: none;
            color: var(--warning);
            font-size: 1rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 15px;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .logout-btn:hover {
            background-color: rgba(247, 37, 133, 0.1);
        }

        /* Form Styles */
        .form-container {
            background: white;
            border-radius: 16px;
            padding: 30px;
            box-shadow: var(--card-shadow);
            max-width: 600px;
            margin: 0 auto;
        }

        .form-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .form-header h3 {
            font-size: 1.8rem;
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 10px;
        }

        .form-header p {
            color: var(--gray);
            font-size: 1rem;
        }

        .message {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .message.success {
            background: rgba(76, 201, 240, 0.1);
            color: var(--success);
            border: 1px solid rgba(76, 201, 240, 0.3);
        }

        .message.error {
            background: rgba(247, 37, 133, 0.1);
            color: var(--warning);
            border: 1px solid rgba(247, 37, 133, 0.3);
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            font-weight: 500;
            color: var(--dark);
            margin-bottom: 8px;
            font-size: 0.95rem;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--border);
            border-radius: 10px;
            font-size: 1rem;
            font-family: 'Poppins', sans-serif;
            transition: all 0.3s ease;
            background: white;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
        }

        .form-group input::placeholder {
            color: var(--gray);
        }

        .form-group select {
            cursor: pointer;
        }

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            justify-content: center;
        }

        .btn {
            padding: 12px 30px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: none;
            font-family: 'Poppins', sans-serif;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--secondary);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(67, 97, 238, 0.3);
        }

        .btn-secondary {
            background: var(--light-gray);
            color: var(--dark);
        }

        .btn-secondary:hover {
            background: var(--gray);
            color: white;
            transform: translateY(-2px);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }

            .sidebar {
                position: relative;
                width: 100%;
                height: auto;
            }

            .main-content {
                grid-column: 1;
                padding: 15px 20px;
            }

            .form-container {
                padding: 20px;
                margin: 0;
            }

            .form-actions {
                flex-direction: column;
            }
        }

        /* Loading Animation */
        .loading {
            opacity: 0.6;
            pointer-events: none;
        }

        .btn-primary.loading::after {
            content: '';
            width: 16px;
            height: 16px;
            border: 2px solid transparent;
            border-top: 2px solid white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 8px;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar Navigation -->
        <div class="sidebar">
            <div class="brand">
                <h1><i class="fas fa-money-bill-wave"></i> Expense Tracker</h1>
            </div>
            <div class="nav-menu">
                <div class="nav-item">
                    <a href="expense?action=dashboard" class="nav-link">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                </div>
                <div class="nav-item active">
                    <a href="add-expense.jsp" class="nav-link">
                        <i class="fas fa-plus-circle"></i>
                        <span>Add Expense</span>
                    </a>
                </div>
                <div class="nav-item">
                    <a href="expense?action=view" class="nav-link">
                        <i class="fas fa-list"></i>
                        <span>View Expenses</span>
                    </a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="fas fa-chart-pie"></i>
                        <span>Reports</span>
                    </a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="fas fa-cog"></i>
                        <span>Settings</span>
                    </a>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">

            <!-- Add Expense Form -->
            <div class="form-container">
                <div class="form-header">
                    <h3><i class="fas fa-plus-circle" style="color: var(--primary); margin-right: 10px;"></i>Add New Expense</h3>
                    <p>Track your spending by adding expense details below</p>
                </div>

                <% if (request.getParameter("success") != null) { %>
                    <div class="message success">
                        <i class="fas fa-check-circle"></i>
                        Expense added successfully! You can add another expense or go back to dashboard.
                    </div>
                <% } else if (request.getParameter("error") != null) { %>
                    <div class="message error">
                        <i class="fas fa-exclamation-circle"></i>
                        Failed to add expense! Please try again or contact support if the problem persists.
                    </div>
                <% } %>

                <form action="expense" method="post" id="expenseForm">
                    <input type="hidden" name="action" value="add">

                    <div class="form-group">
                        <label for="title">
                            <i class="fas fa-pencil-alt" style="margin-right: 5px; color: var(--primary);"></i>
                            Expense Title
                        </label>
                        <input type="text"
                               id="title"
                               name="title"
                               required
                               placeholder="e.g., Lunch at restaurant, Gas for car, Movie tickets..."
                               maxlength="100">
                    </div>

                    <div class="form-group">
                        <label for="amount">
                            <i class="fas fa-rupee-sign" style="margin-right: 5px; color: var(--success);"></i>
                            Amount (₹)
                        </label>
                        <input type="number"
                               id="amount"
                               name="amount"
                               step="0.01"
                               min="0.01"
                               required
                               placeholder="0.00">
                    </div>

                    <div class="form-group">
                        <label for="date">
                            <i class="fas fa-calendar-alt" style="margin-right: 5px; color: var(--secondary);"></i>
                            Date
                        </label>
                        <input type="date"
                               id="date"
                               name="date"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="category">
                            <i class="fas fa-tags" style="margin-right: 5px; color: var(--warning);"></i>
                            Category
                        </label>
                        <select id="category" name="category" required>
                            <option value="">-- Select Category --</option>
                            <option value="Food">🍽️ Food & Dining</option>
                            <option value="Transport">🚗 Transportation</option>
                            <option value="Shopping">🛍️ Shopping</option>
                            <option value="Entertainment">🎬 Entertainment</option>
                            <option value="Bills">📄 Bills & Utilities</option>
                            <option value="Health">⚕️ Health & Medical</option>
                            <option value="Education">📚 Education</option>
                            <option value="Travel">✈️ Travel</option>
                            <option value="Others">📦 Others</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            <i class="fas fa-plus"></i>
                            Add Expense
                        </button>
                        <a href="expense?action=dashboard" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i>
                            Back to Dashboard
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Set today's date as default
        document.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('date');
            const today = new Date().toISOString().split('T')[0];
            dateInput.value = today;
            dateInput.max = today; // Prevent future dates
        });

        // Form submission handling
        document.getElementById('expenseForm').addEventListener('submit', function(e) {
            const submitBtn = document.getElementById('submitBtn');
            const form = this;

            // Basic validation
            const title = document.getElementById('title').value.trim();
            const amount = parseFloat(document.getElementById('amount').value);
            const date = document.getElementById('date').value;
            const category = document.getElementById('category').value;

            if (!title || !amount || !date || !category) {
                e.preventDefault();
                alert('Please fill in all required fields.');
                return;
            }

            if (amount <= 0) {
                e.preventDefault();
                alert('Amount must be greater than 0.');
                return;
            }

            // Add loading state
            submitBtn.classList.add('loading');
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding Expense...';
            submitBtn.disabled = true;
        });

        // Logout functionality
        function handleLogout() {
            if (confirm('Are you sure you want to logout?')) {
                window.location.href = 'logout.jsp';
            }
        }

        // Auto-focus on first input
        document.getElementById('title').focus();

        // Format amount input
        document.getElementById('amount').addEventListener('input', function(e) {
            const value = e.target.value;
            if (value && !isNaN(value)) {
                const formatted = parseFloat(value).toFixed(2);
                if (formatted !== value && !value.endsWith('.')) {
                    e.target.value = formatted;
                }
            }
        });

        // Enhanced form validation
        function validateForm() {
            const title = document.getElementById('title').value.trim();
            const amount = document.getElementById('amount').value;
            const date = document.getElementById('date').value;
            const category = document.getElementById('category').value;

            let isValid = true;
            let errorMessage = '';

            if (!title || title.length < 3) {
                errorMessage = 'Title must be at least 3 characters long.';
                isValid = false;
            } else if (!amount || parseFloat(amount) <= 0) {
                errorMessage = 'Please enter a valid amount greater than 0.';
                isValid = false;
            } else if (!date) {
                errorMessage = 'Please select a date.';
                isValid = false;
            } else if (!category) {
                errorMessage = 'Please select a category.';
                isValid = false;
            }

            if (!isValid) {
                alert(errorMessage);
            }

            return isValid;
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Ctrl+Enter to submit form
            if (e.ctrlKey && e.key === 'Enter') {
                document.getElementById('expenseForm').submit();
            }
            // Escape to go back
            if (e.key === 'Escape') {
                window.location.href = 'expense?action=dashboard';
            }
        });
    </script>
</body>
</html>