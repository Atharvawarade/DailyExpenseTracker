package com.expensetracker.controller;

import com.expensetracker.dao.ExpenseDAO;
import com.expensetracker.model.Expense;
import com.expensetracker.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/expense")
public class ExpenseServlet extends HttpServlet {

    private ExpenseDAO expenseDAO;

    @Override
    public void init() throws ServletException {
        expenseDAO = new ExpenseDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addExpense(request, response);
        } else {
            response.sendRedirect("index.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("view".equals(action)) {
            viewExpenses(request, response);
        } else if ("dashboard".equals(action)) {
            getDashboardData(request, response);
        } else {
            response.sendRedirect("index.jsp");
        }
    }

    private void addExpense(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            HttpSession session = request.getSession(false);
            User user = (User) session.getAttribute("user");

            if (user == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String title = request.getParameter("title");
            double amount = Double.parseDouble(request.getParameter("amount"));
            String dateStr = request.getParameter("date");
            String category = request.getParameter("category");

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date date = sdf.parse(dateStr);

            Expense expense = new Expense(title, amount, date, category, user);
            expenseDAO.saveExpense(expense);

            response.sendRedirect("add-expense.jsp?success=true");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("add-expense.jsp?error=true");
        }
    }

    private void viewExpenses(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            User user = (User) session.getAttribute("user");

            if (user == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            List<Expense> expenses = expenseDAO.getExpensesByUser(user);
            request.setAttribute("expenses", expenses);
            request.getRequestDispatcher("view-expenses.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp");
        }
    }

    private void getDashboardData(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            User user = (User) session.getAttribute("user");

            if (user == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            // Get all expenses for the user
            List<Expense> allExpenses = expenseDAO.getExpensesByUser(user);

            // Calculate dashboard metrics
            Map<String, Object> dashboardData = calculateDashboardMetrics(allExpenses);

            // Set attributes for JSP
            for (Map.Entry<String, Object> entry : dashboardData.entrySet()) {
                request.setAttribute(entry.getKey(), entry.getValue());
            }

            request.getRequestDispatcher("index.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
        }
    }

    private Map<String, Object> calculateDashboardMetrics(List<Expense> expenses) {
        Map<String, Object> data = new HashMap<>();

        if (expenses == null || expenses.isEmpty()) {
            data.put("totalSpent", 0.0);
            data.put("averageDaily", 0.0);
            data.put("remainingBudget", 2500.0); // Default budget
            data.put("activeCategories", 0);
            data.put("recentExpenses", new ArrayList<>());
            data.put("categoryData", new HashMap<>());
            data.put("dailyExpenses", new ArrayList<>());
            data.put("dailyLabels", new ArrayList<>());
            data.put("dailyValues", new ArrayList<>());
            return data;
        }

        Calendar now = Calendar.getInstance();
        Calendar monthStart = Calendar.getInstance();
        monthStart.set(Calendar.DAY_OF_MONTH, 1);
        monthStart.set(Calendar.HOUR_OF_DAY, 0);
        monthStart.set(Calendar.MINUTE, 0);
        monthStart.set(Calendar.SECOND, 0);

        // Filter expenses for current month
        List<Expense> monthlyExpenses = new ArrayList<>();
        for (Expense expense : expenses) {
            Calendar expenseDate = Calendar.getInstance();
            expenseDate.setTime(expense.getDate());
            if (!expenseDate.before(monthStart)) {
                monthlyExpenses.add(expense);
            }
        }

        // Calculate total spent this month
        double totalSpent = monthlyExpenses.stream()
                .mapToDouble(Expense::getAmount)
                .sum();

        // Calculate average daily expense
        int daysInMonth = now.get(Calendar.DAY_OF_MONTH);
        double averageDaily = daysInMonth > 0 ? totalSpent / daysInMonth : 0;

        // Calculate remaining budget (assuming 2500 monthly budget)
        double budget = 2500.0;
        double remainingBudget = budget - totalSpent;

        // Count active categories
        Set<String> categories = new HashSet<>();
        for (Expense expense : monthlyExpenses) {
            if (expense.getCategory() != null && !expense.getCategory().trim().isEmpty()) {
                categories.add(expense.getCategory());
            }
        }

        // Get recent expenses (last 5)
        List<Expense> recentExpenses = new ArrayList<>(expenses);
        recentExpenses.sort((e1, e2) -> e2.getDate().compareTo(e1.getDate()));
        if (recentExpenses.size() > 5) {
            recentExpenses = recentExpenses.subList(0, 5);
        }

        // Calculate category-wise spending
        Map<String, Double> categoryData = new HashMap<>();
        for (Expense expense : monthlyExpenses) {
            String category = expense.getCategory();
            if (category == null || category.trim().isEmpty()) {
                category = "Others";
            }
            categoryData.put(category, categoryData.getOrDefault(category, 0.0) + expense.getAmount());
        }

        // Calculate daily expenses for chart (last 30 days)
        Map<String, Double> dailyExpensesMap = new TreeMap<>();
        List<String> dailyLabels = new ArrayList<>();
        List<Double> dailyValues = new ArrayList<>();

        Calendar chartStart = Calendar.getInstance();
        chartStart.add(Calendar.DAY_OF_MONTH, -29); // Last 30 days
        SimpleDateFormat labelFormat = new SimpleDateFormat("MMM dd");

        // Initialize all days with 0
        for (int i = 0; i < 30; i++) {
            String dateKey = labelFormat.format(chartStart.getTime());
            dailyExpensesMap.put(dateKey, 0.0);
            chartStart.add(Calendar.DAY_OF_MONTH, 1);
        }

        // Add actual expenses to corresponding days
        for (Expense expense : expenses) {
            Calendar expenseDate = Calendar.getInstance();
            expenseDate.setTime(expense.getDate());

            Calendar thirtyDaysAgo = Calendar.getInstance();
            thirtyDaysAgo.add(Calendar.DAY_OF_MONTH, -29);

            if (!expenseDate.before(thirtyDaysAgo)) {
                String dateKey = labelFormat.format(expense.getDate());
                if (dailyExpensesMap.containsKey(dateKey)) {
                    dailyExpensesMap.put(dateKey, dailyExpensesMap.get(dateKey) + expense.getAmount());
                }
            }
        }

        // Convert to lists for chart
        for (Map.Entry<String, Double> entry : dailyExpensesMap.entrySet()) {
            dailyLabels.add(entry.getKey());
            dailyValues.add(entry.getValue());
        }

        data.put("totalSpent", totalSpent);
        data.put("averageDaily", averageDaily);
        data.put("remainingBudget", remainingBudget);
        data.put("activeCategories", categories.size());
        data.put("recentExpenses", recentExpenses);
        data.put("categoryData", categoryData);
        data.put("dailyExpenses", dailyExpensesMap);
        data.put("dailyLabels", dailyLabels);
        data.put("dailyValues", dailyValues);

        return data;
    }
}