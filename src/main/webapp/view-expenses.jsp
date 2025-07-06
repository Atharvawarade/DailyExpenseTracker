<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.*, com.expensetracker.model.Expense" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Forward to servlet to get expenses data
    if (request.getAttribute("expenses") == null) {
        request.getRequestDispatcher("expense?action=view").forward(request, response);
        return;
    }

    com.expensetracker.model.User user = (com.expensetracker.model.User) session.getAttribute("user");
    String name = user.getName();
    String initials = name.length() >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();

    DecimalFormat df = new DecimalFormat("#.##");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>

<html>
<head>
    <title>View Expenses - Daily Expense Tracker</title>
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

        /* Expenses Container */
        .expenses-container {
            background: white;
            border-radius: 16px;
            padding: 30px;
            box-shadow: var(--card-shadow);
        }

        .expenses-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .expenses-title {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .expenses-title h3 {
            font-size: 1.8rem;
            font-weight: 600;
            color: var(--dark);
        }

        .expenses-title i {
            color: var(--primary);
            font-size: 1.5rem;
        }

        .add-expense-btn {
            background: var(--primary);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 10px;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .add-expense-btn:hover {
            background: var(--secondary);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(67, 97, 238, 0.3);
        }

        /* Filters */
        .filters-container {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
            flex-wrap: wrap;
            align-items: center;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .filter-group label {
            font-weight: 500;
            color: var(--gray);
            font-size: 0.9rem;
        }

        .filter-group select {
            padding: 8px 12px;
            border: 2px solid var(--border);
            border-radius: 8px;
            font-size: 0.9rem;
            font-family: 'Poppins', sans-serif;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .filter-group select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
        }

        .clear-filters-btn {
            background: var(--light-gray);
            color: var(--dark);
            border: none;
            padding: 8px 15px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .clear-filters-btn:hover {
            background: var(--gray);
            color: white;
        }

        /* Table Styles */
        .expenses-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }

        .expenses-table th,
        .expenses-table td {
            padding: 15px 12px;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }

        .expenses-table th {
            background: var(--light);
            font-weight: 600;
            color: var(--dark);
            font-size: 0.95rem;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .expenses-table tbody tr {
            transition: all 0.3s ease;
        }

        .expenses-table tbody tr:hover {
            background-color: rgba(67, 97, 238, 0.05);
        }

        .expenses-table tbody tr:nth-child(even) {
            background-color: rgba(248, 249, 250, 0.5);
        }

        .expenses-table tbody tr:nth-child(even):hover {
            background-color: rgba(67, 97, 238, 0.05);
        }

        .sr-no {
            font-weight: 600;
            color: var(--gray);
            width: 60px;
        }

        .expense-title {
            font-weight: 500;
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .expense-amount {
            font-weight: 600;
            color: var(--primary);
            font-size: 1.05rem;
        }

        .expense-date {
            color: var(--gray);
            font-size: 0.9rem;
        }

        .expense-category {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
        }

        .category-food {
            background: rgba(76, 201, 240, 0.15);
            color: var(--success);
        }

        .category-shopping {
            background: rgba(247, 37, 133, 0.15);
            color: var(--warning);
        }

        .category-transport {
            background: rgba(63, 55, 201, 0.15);
            color: var(--secondary);
        }

        .category-entertainment {
            background: rgba(67, 97, 238, 0.15);
            color: var(--primary);
        }

        .category-bills {
            background: rgba(255, 193, 7, 0.15);
            color: #f57c00;
        }

        .category-health {
            background: rgba(220, 53, 69, 0.15);
            color: #dc3545;
        }

        .category-education {
            background: rgba(13, 202, 240, 0.15);
            color: #0dcaf0;
        }

        .category-travel {
            background: rgba(25, 135, 84, 0.15);
            color: #198754;
        }

        .category-others {
            background: rgba(108, 117, 125, 0.15);
            color: var(--gray);
        }

        /* Summary */
        .expenses-summary {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 12px;
            color: white;
            margin-top: 20px;
        }

        .summary-item {
            text-align: center;
        }

        .summary-item .label {
            font-size: 0.9rem;
            opacity: 0.9;
            margin-bottom: 5px;
        }

        .summary-item .value {
            font-size: 1.5rem;
            font-weight: 600;
        }

        .no-data {
            text-align: center;
            padding: 40px;
            color: var(--gray);
        }

        .no-data i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        .no-data h4 {
            margin-bottom: 10px;
            font-size: 1.2rem;
        }

        .no-data p {
            margin-bottom: 20px;
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

            .expenses-container {
                padding: 20px;
            }

            .filters-container {
                flex-direction: column;
                gap: 15px;
            }

            .filter-group {
                width: 100%;
            }

            .expenses-table {
                font-size: 0.9rem;
            }

            .expenses-table th,
            .expenses-table td {
                padding: 10px 8px;
            }

            .expenses-summary {
                flex-direction: column;
                gap: 15px;
            }
        }

        /* Scrollable table for mobile */
        .table-container {
            overflow-x: auto;
            border-radius: 8px;
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
                <div class="nav-item">
                    <a href="add-expense.jsp" class="nav-link">
                        <i class="fas fa-plus-circle"></i>
                        <span>Add Expense</span>
                    </a>
                </div>
                <div class="nav-item active">
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
            <!-- Expenses Container -->
            <div class="expenses-container">
                <div class="expenses-header">
                    <div class="expenses-title">
                        <i class="fas fa-list"></i>
                        <h3>All Expenses</h3>
                    </div>
                    <a href="add-expense.jsp" class="add-expense-btn">
                        <i class="fas fa-plus"></i>
                        <span>Add Expense</span>
                    </a>
                </div>

                <!-- Filters -->
                <div class="filters-container">
                    <div class="filter-group">
                        <label>Sort by Amount</label>
                        <select id="sortAmount">
                            <option value="">Default</option>
                            <option value="asc">Amount: Low to High</option>
                            <option value="desc">Amount: High to Low</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>Filter by Category</label>
                        <select id="filterCategory">
                            <option value="">All Categories</option>
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
                    <button class="clear-filters-btn" onclick="clearFilters()">
                        <i class="fas fa-times"></i> Clear Filters
                    </button>
                </div>

                <%
                    List<Expense> expenses = (List<Expense>) request.getAttribute("expenses");
                    if (expenses != null && !expenses.isEmpty()) {
                        // Sort expenses by date (recent first) by default
                        expenses.sort((e1, e2) -> e2.getDate().compareTo(e1.getDate()));
                %>
                <div class="table-container">
                    <table class="expenses-table" id="expensesTable">
                        <thead>
                            <tr>
                                <th>Sr. No.</th>
                                <th>Title</th>
                                <th>Amount (₹)</th>
                                <th>Date</th>
                                <th>Category</th>
                            </tr>
                        </thead>
                        <tbody id="expensesTableBody">
                            <%
                                int srNo = 1;
                                for (Expense expense : expenses) {
                                    String category = expense.getCategory();
                                    if (category == null || category.trim().isEmpty()) category = "Others";

                                    String categoryClass = "category-others";
                                    if (category.toLowerCase().contains("food")) categoryClass = "category-food";
                                    else if (category.toLowerCase().contains("shop")) categoryClass = "category-shopping";
                                    else if (category.toLowerCase().contains("transport")) categoryClass = "category-transport";
                                    else if (category.toLowerCase().contains("entertainment")) categoryClass = "category-entertainment";
                                    else if (category.toLowerCase().contains("bills")) categoryClass = "category-bills";
                                    else if (category.toLowerCase().contains("health")) categoryClass = "category-health";
                                    else if (category.toLowerCase().contains("education")) categoryClass = "category-education";
                                    else if (category.toLowerCase().contains("travel")) categoryClass = "category-travel";
                            %>
                            <tr data-amount="<%= expense.getAmount() %>" data-category="<%= category %>">
                                <td class="sr-no"><%= srNo++ %></td>
                                <td class="expense-title" title="<%= expense.getTitle() %>"><%= expense.getTitle() %></td>
                                <td class="expense-amount">₹<%= df.format(expense.getAmount()) %></td>
                                <td class="expense-date"><%= dateFormat.format(expense.getDate()) %></td>
                                <td><span class="expense-category <%= categoryClass %>"><%= category %></span></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>


                <% } %>
            </div>
        </div>
    </div>

    <script>
        let originalData = [];
        let currentData = [];

        // Initialize data
        document.addEventListener('DOMContentLoaded', function() {
            const tableBody = document.getElementById('expensesTableBody');
            if (tableBody) {
                const rows = Array.from(tableBody.querySelectorAll('tr'));
                originalData = rows.map(row => ({
                    element: row,
                    amount: parseFloat(row.dataset.amount),
                    category: row.dataset.category,
                    srNo: parseInt(row.querySelector('.sr-no').textContent)
                }));
                currentData = [...originalData];
            }

            // Event listeners
            document.getElementById('sortAmount').addEventListener('change', applyFilters);
            document.getElementById('filterCategory').addEventListener('change', applyFilters);
        });

        function applyFilters() {
            const sortAmount = document.getElementById('sortAmount').value;
            const filterCategory = document.getElementById('filterCategory').value;

            // Start with original data
            currentData = [...originalData];

            // Apply category filter
            if (filterCategory) {
                currentData = currentData.filter(item => item.category === filterCategory);
            }

            // Apply sorting
            if (sortAmount === 'asc') {
                currentData.sort((a, b) => a.amount - b.amount);
            } else if (sortAmount === 'desc') {
                currentData.sort((a, b) => b.amount - a.amount);
            }

            // Update table
            updateTable();
            updateSummary();
        }

        function updateTable() {
            const tableBody = document.getElementById('expensesTableBody');
            tableBody.innerHTML = '';

            currentData.forEach((item, index) => {
                // Update serial number
                item.element.querySelector('.sr-no').textContent = index + 1;
                tableBody.appendChild(item.element);
            });
        }

        function updateSummary() {
            const totalCount = originalData.length;
            const filteredCount = currentData.length;
            const filteredAmount = currentData.reduce((sum, item) => sum + item.amount, 0);

            document.getElementById('totalCount').textContent = totalCount;
            document.getElementById('filteredCount').textContent = filteredCount;

            // Update filtered amount display
            const totalAmountElement = document.getElementById('totalAmount');
            if (filteredCount !== totalCount) {
                totalAmountElement.textContent = `₹${filteredAmount.toFixed(2)}`;
                totalAmountElement.style.color = '#f72585';
            } else {
                totalAmountElement.textContent = `₹${filteredAmount.toFixed(2)}`;
                totalAmountElement.style.color = 'white';
            }
        }

        function clearFilters() {
            document.getElementById('sortAmount').value = '';
            document.getElementById('filterCategory').value = '';

            // Reset to original data
            currentData = [...originalData];
            updateTable();
            updateSummary();
        }

        function handleLogout() {
            if (confirm('Are you sure you want to logout?')) {
                window.location.href = 'logout.jsp';
            }
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Escape to clear filters
            if (e.key === 'Escape') {
                clearFilters();
            }
            // Ctrl+N to add new expense
            if (e.ctrlKey && e.key === 'n') {
                e.preventDefault();
                window.location.href = 'add-expense.jsp';
            }
        });

        // Enhanced table interactions
        document.querySelectorAll('.expenses-table tbody tr').forEach(row => {
            row.addEventListener('click', function() {
                // Add click effect
                this.style.backgroundColor = 'rgba(67, 97, 238, 0.1)';
                setTimeout(() => {
                    this.style.backgroundColor = '';
                }, 200);
            });
        });
    </script>
</body>
</html>