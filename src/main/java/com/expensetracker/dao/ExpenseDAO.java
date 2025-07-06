package com.expensetracker.dao;

import com.expensetracker.model.Expense;
import com.expensetracker.util.DBConnection;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import com.expensetracker.model.User;

import java.util.List;

public class ExpenseDAO {

    // Save a new expense
    public void saveExpense(Expense expense) {
        Transaction transaction = null;
        try (Session session = DBConnection.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.save(expense);
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
        }
    }

    // Fetch all expenses
    public List<Expense> getAllExpenses(User user) {
        try (Session session = DBConnection.getSessionFactory().openSession()) {
            Query<Expense> query = session.createQuery(
                    "FROM Expense e WHERE e.user = :user", Expense.class);
            query.setParameter("user", user);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    // Get expense by ID
    public List<Expense> getExpensesByUser(User user) {
        try (Session session = DBConnection.getSessionFactory().openSession()) {
            Query<Expense> query = session.createQuery(
                    "FROM Expense WHERE user = :user", Expense.class);
            query.setParameter("user", user);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    // Update an existing expense
    public void updateExpense(Expense expense) {
        Transaction transaction = null;
        try (Session session = DBConnection.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.update(expense);
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
        }
    }

    // Delete an expense
    public void deleteExpense(int id) {
        Transaction transaction = null;
        try (Session session = DBConnection.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            Expense expense = session.get(Expense.class, id);
            if (expense != null) {
                session.delete(expense);
            }
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
        }
    }
}
