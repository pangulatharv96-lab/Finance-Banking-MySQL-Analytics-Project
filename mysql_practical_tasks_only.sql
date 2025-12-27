
-- =============================================
-- MYSQL PRACTICAL TASKS (FINANCE / BANKING)
-- =============================================

USE finance_banking_db;
select * from branches;
select * from `customers`;
select * from `fraud_alerts`;
select * from `loan_types`;
select * from `loans`;
select * from `numbers`;
select * from `payment_history`;


-- ======================
-- TASK 1: DATA CHECK
-- ======================
-- Find total number of customers.
select count(*) from customers;
-- Find total number of loans.
select count(*) from loans;

-- ======================
-- TASK 2: BASIC FILTERING
-- ======================
-- Display all ACTIVE loans.
select * from loans 
where loan_status ='Active';

-- Display loans disbursed after 1-Jan-2022.
SELECT * FROM loans
WHERE disbursed_date > '2022-01-01';

-- ======================
-- TASK 3: AGGREGATION
-- ======================
-- Find total loan amount by branch.
SELECT branch_id, SUM(loan_amount) AS total_loan_amount
FROM loans
GROUP BY branch_id;

-- Find average loan amount by loan type.
select loan_type, avg(loan_amount) as average_loan_amount
from loans
group by loan_type;

-- ======================
-- TASK 4: JOINS
-- ======================
-- Display customer name, loan amount, loan type.
SELECT c.customer_name, l.loan_amount, l.loan_type
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id;


-- Display branch name with total loan count.
SELECT b.branch_name, COUNT(l.loan_id) AS total_loans
FROM branches b
LEFT JOIN loans l ON b.branch_id = l.branch_id
GROUP BY b.branch_name;

-- ======================
-- TASK 5: CREDIT RISK ANALYSIS
-- ======================
-- List customers with credit score below 650.
select * from customers
where credit_score < 650;
-- Count number of loans under HIGH risk loan types.
SELECT COUNT(*) AS high_risk_loans
FROM loans
WHERE loan_type = 'HIGH_RISK';

-- ======================
-- TASK 6: PAYMENT ANALYSIS
-- ======================

-- Identify loans with missed EMI.
select distinct loan_id
from `payment_history`
where `payment_status` = "Missed";

-- Calculate average delay days per loan.
SELECT loan_id, AVG(days_delayed) AS avg_delay_days
FROM payment_history
GROUP BY loan_id;

-- ======================
-- TASK 7: FRAUD ANALYSIS
-- ======================
-- Count fraud alerts by risk level.
SELECT risk_level, COUNT(*) AS alert_count
FROM fraud_alerts
GROUP BY risk_level;

-- Identify customers with more than one fraud alert.
SELECT customer_id, COUNT(*) AS alert_count
FROM fraud_alerts
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- ======================
-- TASK 8: SUBQUERIES
-- ======================
-- Find customers whose loan amount is above average.
SELECT DISTINCT customer_id
FROM loans
WHERE loan_amount > (SELECT AVG(loan_amount) FROM loans);

-- Identify branch with highest number of default loans.
SELECT branch_id
FROM loans
WHERE loan_status = 'Default'
GROUP BY branch_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- ======================
-- TASK 9: CASE STATEMENT
-- ======================
-- Create a query to classify customers as:
-- High Risk (<650), Medium Risk (650–749), Low Risk (>=750)
SELECT customer_id, customer_name, credit_score,
CASE
    WHEN credit_score < 650 THEN 'High Risk'
    WHEN credit_score BETWEEN 650 AND 749 THEN 'Medium Risk'
    ELSE 'Low Risk'
END AS risk_category
FROM customers;

-- ======================
-- TASK 10: BUSINESS QUERY
-- ======================
-- Identify branch and loan type combination
-- with highest default rate.

-- ======================
-- TASK 11: DATE FUNCTIONS
-- ======================
-- Find number of loans disbursed year-wise.
SELECT YEAR(`disbursed_date`) AS year, COUNT(*) AS total_loans
FROM loans
GROUP BY YEAR(`disbursed_date`);

-- Find loans disbursed in the last 6 months.

-- ======================
-- TASK 12: WINDOW FUNCTIONS
-- ======================
-- Rank customers based on total loan amount.
SELECT customer_id,
SUM(loan_amount) AS total_loan_amount,
RANK() OVER (ORDER BY SUM(loan_amount) DESC) AS loan_rank
FROM loans
GROUP BY customer_id;

-- Calculate running total of loan amount by date.
SELECT loan_id, disbursed_date, loan_amount,
SUM(loan_amount) OVER (ORDER BY disbursed_date) AS running_total
FROM loans;

-- ======================
-- TASK 13: PERFORMANCE
-- ======================
-- Suggest indexes to optimize loan and payment queries.
CREATE INDEX idx_loans_customer ON loans(customer_id);
CREATE INDEX idx_loans_branch ON loans(branch_id);
CREATE INDEX idx_loans_status_date ON loans(loan_status, disbursed_date);
CREATE INDEX idx_payment_loan ON payment_history(loan_id);
CREATE INDEX idx_fraud_customer ON fraud_alerts(customer_id);

-- ======================
-- TASK 14: DATA QUALITY
-- ======================
-- Identify duplicate customer records (if any).
SELECT customer_name, COUNT(*)
FROM customers
GROUP BY customer_name
HAVING COUNT(*) > 1;

-- Identify loans without payment records.
SELECT l.loan_id
FROM loans l
LEFT JOIN payment_history p ON l.loan_id = p.loan_id
WHERE p.loan_id IS NULL;

-- ======================
-- TASK 15: INSIGHT
-- ======================
-- Write SQL queries to support:
-- 1. Which branch has highest credit risk?
SELECT l.branch_id, AVG(c.credit_score) AS avg_score
FROM customers c
GROUP BY l.branch_id
ORDER BY avg_score ASC
LIMIT 1;

-- 2. Which loan type should be restricted?
SELECT loan_type
