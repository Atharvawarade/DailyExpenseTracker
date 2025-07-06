<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.*, com.expensetracker.model.Expense" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Forward to servlet to get dashboard data
    if (request.getAttribute("totalSpent") == null) {
        request.getRequestDispatcher("expense?action=dashboard").forward(request, response);
        return;
    }
%>
<%
    com.expensetracker.model.User user = (com.expensetracker.model.User) session.getAttribute("user");
    String name = user.getName();
    String initials = name.length() >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();

    // Get dashboard data from request attributes
    Double totalSpent = (Double) request.getAttribute("totalSpent");
    Double averageDaily = (Double) request.getAttribute("averageDaily");
    Double remainingBudget = (Double) request.getAttribute("remainingBudget");
    Integer activeCategories = (Integer) request.getAttribute("activeCategories");
    List<Expense> recentExpenses = (List<Expense>) request.getAttribute("recentExpenses");
    Map<String, Double> categoryData = (Map<String, Double>) request.getAttribute("categoryData");
    Map<String, Double> dailyExpenses = (Map<String, Double>) request.getAttribute("dailyExpenses");

    DecimalFormat df = new DecimalFormat("#.##");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a");
%>

<html>
<head>
    <title>Daily Expense Tracker Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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

        /* Dashboard Widgets */
        .dashboard-widgets {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .widget {
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: var(--card-shadow);
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .widget-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
        }

        .widget-info h3 {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .widget-info p {
            color: var(--gray);
            font-size: 0.95rem;
        }

        .widget.total .widget-icon {
            background: rgba(67, 97, 238, 0.15);
            color: var(--primary);
        }

        .widget.daily .widget-icon {
            background: rgba(76, 201, 240, 0.15);
            color: var(--success);
        }

        .widget.remaining .widget-icon {
            background: rgba(247, 37, 133, 0.15);
            color: var(--warning);
        }

        .widget.categories .widget-icon {
            background: rgba(63, 55, 201, 0.15);
            color: var(--secondary);
        }

        /* Charts Section */
        .charts-container {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        .chart-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: var(--card-shadow);
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .chart-header h3 {
            font-size: 1.2rem;
            font-weight: 600;
        }

        .chart-actions {
            display: flex;
            gap: 10px;
        }

        .chart-actions button {
            background: none;
            border: 1px solid var(--border);
            color: var(--gray);
            padding: 5px 10px;
            border-radius: 6px;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .chart-actions button:hover {
            background-color: var(--light);
        }

        .chart-container {
            height: 300px;
            position: relative;
        }

        /* Recent Transactions */
        .recent-transactions {
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: var(--card-shadow);
        }

        .transactions-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .transactions-header h3 {
            font-size: 1.2rem;
            font-weight: 600;
        }

        .add-expense-btn {
            background: var(--primary);
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .add-expense-btn:hover {
            background: var(--secondary);
        }

        .transactions-table {
            width: 100%;
            border-collapse: collapse;
        }

        .transactions-table th,
        .transactions-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }

        .transactions-table th {
            font-weight: 500;
            color: var(--gray);
            font-size: 0.9rem;
        }

        .transactions-table tbody tr:hover {
            background-color: var(--light);
        }

        .expense-category {
            display: inline-block;
            padding: 4px 10px;
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

        .category-others {
            background: rgba(108, 117, 125, 0.15);
            color: var(--gray);
        }

        .expense-amount {
            font-weight: 600;
        }

        .no-data {
            text-align: center;
            color: var(--gray);
            padding: 20px;
            font-style: italic;
        }

        /* Responsive */
        @media (max-width: 992px) {
            .charts-container {
                grid-template-columns: 1fr;
            }
        }

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
                <div class="nav-item active">
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
            <div class="header">
                <div class="user-info">
                    <div class="user-avatar"><%= initials %></div>
                    <div class="user-details">
                        <h2><%= name %></h2>
                        <p>Welcome back to your expense dashboard</p>
                    </div>
                </div>
                <button class="logout-btn" onclick="window.location.href='logout.jsp'">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </button>
            </div>

            <!-- Dashboard Widgets -->
            <div class="dashboard-widgets">
                <div class="widget total">
                    <div class="widget-icon">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div class="widget-info">
                        <h3>₹<%= df.format(totalSpent) %></h3>
                        <p>Total Spent This Month</p>
                    </div>
                </div>

                <div class="widget daily">
                    <div class="widget-icon">
                        <i class="fas fa-calendar-day"></i>
                    </div>
                    <div class="widget-info">
                        <h3>₹<%= df.format(averageDaily) %></h3>
                        <p>Average Daily Expense</p>
                    </div>
                </div>



                <div class="widget categories">
                    <div class="widget-icon">
                        <i class="fas fa-tags"></i>
                    </div>
                    <div class="widget-info">
                        <h3><%= activeCategories %></h3>
                        <p>Active Categories</p>
                    </div>
                </div>
            </div>

            <!-- Charts Section -->
            <div class="charts-container">
                <div class="chart-card">
                    <div class="chart-header">
                        <h3>Daily Expense Trends</h3>
                        <div class="chart-actions">
                            <button>Last 30 Days</button>
                        </div>
                    </div>
                    <div class="chart-container">
                        <canvas id="expenseTrendChart"></canvas>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="chart-header">
                        <h3>Spending by Category</h3>
                        <div class="chart-actions">
                            <button>This Month</button>
                        </div>
                    </div>
                    <div class="chart-container">
                        <canvas id="categoryChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Recent Transactions -->
            <div class="recent-transactions">
                <div class="transactions-header">
                    <h3>Recent Transactions</h3>
                    <a href="add-expense.jsp" class="add-expense-btn">
                        <i class="fas fa-plus"></i>
                        <span>Add Expense</span>
                    </a>
                </div>

                <% if (recentExpenses != null && !recentExpenses.isEmpty()) { %>
                <table class="transactions-table">
                    <thead>
                        <tr>
                            <th>Description</th>
                            <th>Category</th>
                            <th>Date</th>
                            <th>Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Expense expense : recentExpenses) {
                            String category = expense.getCategory();
                            if (category == null || category.trim().isEmpty()) category = "Others";

                            String categoryClass = "category-others";
                            if (category.toLowerCase().contains("food")) categoryClass = "category-food";
                            else if (category.toLowerCase().contains("shop")) categoryClass = "category-shopping";
                            else if (category.toLowerCase().contains("transport")) categoryClass = "category-transport";
                            else if (category.toLowerCase().contains("entertainment")) categoryClass = "category-entertainment";

                            Calendar expenseDate = Calendar.getInstance();
                            expenseDate.setTime(expense.getDate());

                            Calendar today = Calendar.getInstance();
                            Calendar yesterday = Calendar.getInstance();
                            yesterday.add(Calendar.DAY_OF_MONTH, -1);

                            String dateDisplay;
                            if (expenseDate.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                                expenseDate.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)) {
                                dateDisplay = "Today";
                            } else if (expenseDate.get(Calendar.YEAR) == yesterday.get(Calendar.YEAR) &&
                                      expenseDate.get(Calendar.DAY_OF_YEAR) == yesterday.get(Calendar.DAY_OF_YEAR)) {
                                dateDisplay = "Yesterday";
                            } else {
                                dateDisplay = dateFormat.format(expense.getDate());
                            }
                        %>
                        <tr>
                            <td><%= expense.getTitle() %></td>
                            <td><span class="expense-category <%= categoryClass %>"><%= category %></span></td>
                            <td><%= dateDisplay %></td>
                            <td class="expense-amount">₹<%= df.format(expense.getAmount()) %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data">
                    <p>No expenses recorded yet. Start by adding your first expense!</p>
                </div>
                <% } %>
            </div>
        </div>
    </div>

       <script>
                   // Initialize charts after page loads
                   document.addEventListener('DOMContentLoaded', function() {
                       // Get real data from JSP
                       <%
                           // Prepare daily expense data for JavaScript
                           List<String> dailyLabels = (List<String>) request.getAttribute("dailyLabels");
                           List<Double> dailyValues = (List<Double>) request.getAttribute("dailyValues");

                           // Create JavaScript arrays
                           StringBuilder labelsJs = new StringBuilder("[");
                           StringBuilder valuesJs = new StringBuilder("[");

                           if (dailyLabels != null && dailyValues != null) {
                               for (int i = 0; i < dailyLabels.size(); i++) {
                                   if (i > 0) {
                                       labelsJs.append(",");
                                       valuesJs.append(",");
                                   }
                                   labelsJs.append("'").append(dailyLabels.get(i)).append("'");
                                   valuesJs.append(dailyValues.get(i));
                               }
                           }
                           labelsJs.append("]");
                           valuesJs.append("]");

                           // Prepare category data for pie chart
                           StringBuilder categoryLabelsJs = new StringBuilder("[");
                           StringBuilder categoryValuesJs = new StringBuilder("[");
                           StringBuilder categoryColorsJs = new StringBuilder("[");

                           String[] colors = {"#4cc9f0", "#f72585", "#3f37c9", "#4361ee", "#7209b7", "#e76f51", "#2a9d8f", "#264653"};

                           if (categoryData != null && !categoryData.isEmpty()) {
                               int colorIndex = 0;
                               boolean first = true;
                               for (Map.Entry<String, Double> entry : categoryData.entrySet()) {
                                   if (!first) {
                                       categoryLabelsJs.append(",");
                                       categoryValuesJs.append(",");
                                       categoryColorsJs.append(",");
                                   }
                                   categoryLabelsJs.append("'").append(entry.getKey()).append("'");
                                   categoryValuesJs.append(entry.getValue());
                                   categoryColorsJs.append("'").append(colors[colorIndex % colors.length]).append("'");
                                   colorIndex++;
                                   first = false;
                               }
                           } else {
                               // Default empty data
                               categoryLabelsJs.append("'No Data'");
                               categoryValuesJs.append("0");
                               categoryColorsJs.append("'#e9ecef'");
                           }
                           categoryLabelsJs.append("]");
                           categoryValuesJs.append("]");
                           categoryColorsJs.append("]");
                       %>

                       const dailyLabels = <%= labelsJs.toString() %>;
                       const dailyValues = <%= valuesJs.toString() %>;
                       const categoryLabels = <%= categoryLabelsJs.toString() %>;
                       const categoryValues = <%= categoryValuesJs.toString() %>;
                       const categoryColors = <%= categoryColorsJs.toString() %>;

                       // Expense Trend Chart (Line Chart) with real data
                       const trendCtx = document.getElementById('expenseTrendChart').getContext('2d');
                       const expenseTrendChart = new Chart(trendCtx, {
                           type: 'line',
                           data: {
                               labels: dailyLabels.length > 0 ? dailyLabels : ['No Data'],
                               datasets: [{
                                   label: 'Daily Expenses (₹)',
                                   data: dailyValues.length > 0 ? dailyValues : [0],
                                   borderColor: '#4361ee',
                                   backgroundColor: 'rgba(67, 97, 238, 0.1)',
                                   borderWidth: 3,
                                   pointBackgroundColor: '#fff',
                                   pointBorderColor: '#4361ee',
                                   pointBorderWidth: 3,
                                   pointRadius: 5,
                                   tension: 0.3,
                                   fill: true
                               }]
                           },
                           options: {
                               responsive: true,
                               maintainAspectRatio: false,
                               plugins: {
                                   legend: {
                                       display: false
                                   },
                                   tooltip: {
                                       mode: 'index',
                                       intersect: false,
                                       callbacks: {
                                           label: function(context) {
                                               return 'Amount: ₹' + context.parsed.y.toFixed(2);
                                           }
                                       }
                                   }
                               },
                               scales: {
                                   y: {
                                       beginAtZero: true,
                                       grid: {
                                           drawBorder: false
                                       },
                                       ticks: {
                                           callback: function(value) {
                                               return '₹' + value;
                                           }
                                       }
                                   },
                                   x: {
                                       grid: {
                                           display: false
                                       }
                                   }
                               },
                               interaction: {
                                   mode: 'nearest',
                                   axis: 'x',
                                   intersect: false
                               }
                           }
                       });

                       // Category Chart (Doughnut Chart) with real data
                       const categoryCtx = document.getElementById('categoryChart').getContext('2d');
                       const categoryChart = new Chart(categoryCtx, {
                           type: 'doughnut',
                           data: {
                               labels: categoryLabels,
                               datasets: [{
                                   data: categoryValues,
                                   backgroundColor: categoryColors,
                                   borderWidth: 0,
                                   hoverOffset: 10
                               }]
                           },
                           options: {
                               responsive: true,
                               maintainAspectRatio: false,
                               plugins: {
                                   legend: {
                                       position: 'bottom',
                                       labels: {
                                           usePointStyle: true,
                                           padding: 20,
                                           font: {
                                               size: 12
                                           }
                                       }
                                   },
                                   tooltip: {
                                       callbacks: {
                                           label: function(context) {
                                               const label = context.label || '';
                                               const value = context.parsed;
                                               const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                               const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                                               return label + ': ₹' + value.toFixed(2) + ' (' + percentage + '%)';
                                           }
                                       }
                                   }
                               },
                               cutout: '70%'
                           }
                       });

                       // Add click handler for category chart
                       categoryChart.canvas.onclick = function(evt) {
                           const points = categoryChart.getElementsAtEventForMode(evt, 'nearest', { intersect: true }, true);
                           if (points.length) {
                               const firstPoint = points[0];
                               const label = categoryChart.data.labels[firstPoint.index];
                               const value = categoryChart.data.datasets[firstPoint.datasetIndex].data[firstPoint.index];
                               console.log('Category: ' + label + ', Amount: ₹' + value);
                           }
                       };

                       // Logout functionality
                       document.querySelector('.logout-btn').addEventListener('click', function() {
                           if (confirm('Are you sure you want to logout?')) {
                               window.location.href = 'logout.jsp';
                           }
                       });
                   });
               </script>
    </body>
    </html>