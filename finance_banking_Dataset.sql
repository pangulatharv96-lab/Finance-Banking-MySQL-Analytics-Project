
-- =============================================
-- FINANCE / BANKING DATABASE 
-- End-to-End Fixed SQL Script
-- MySQL Compatible | Exam & Production Safe
-- =============================================

-- ======================
-- CREATE DATABASE
-- ======================
CREATE DATABASE IF NOT EXISTS finance_banking_db;
USE finance_banking_db;

-- ======================
-- DROP TABLES (SAFE ORDER)
-- ======================
DROP TABLE IF EXISTS fraud_alerts;
DROP TABLE IF EXISTS payment_history;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS loan_types;
DROP TABLE IF EXISTS branches;
DROP TABLE IF EXISTS numbers;

-- ======================
-- MASTER TABLES
-- ======================

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(50),
    age INT,
    gender CHAR(1),
    annual_income INT,
    employment_type VARCHAR(30),
    credit_score INT,
    city VARCHAR(30)
);

CREATE TABLE branches (
    branch_id VARCHAR(5) PRIMARY KEY,
    branch_name VARCHAR(50),
    city VARCHAR(30),
    region VARCHAR(20)
);

CREATE TABLE loan_types (
    loan_type VARCHAR(30) PRIMARY KEY,
    risk_category VARCHAR(20),
    max_tenure INT
);

-- ======================
-- FACT TABLE
-- ======================

CREATE TABLE loans (
    loan_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    branch_id VARCHAR(5),
    loan_type VARCHAR(30),
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    tenure_years INT,
    loan_status VARCHAR(20),
    disbursed_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (loan_type) REFERENCES loan_types(loan_type)
);

CREATE TABLE payment_history (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id VARCHAR(10),
    payment_date DATE,
    emi_amount DECIMAL(10,2),
    paid_amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    days_delayed INT,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

CREATE TABLE fraud_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(10),
    alert_date DATE,
    alert_type VARCHAR(50),
    risk_level VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ======================
-- MASTER DATA
-- ======================

INSERT INTO branches VALUES
('B01','Pune Main','Pune','West'),
('B02','Mumbai Central','Mumbai','West'),
('B03','Bangalore Hub','Bangalore','South');

INSERT INTO loan_types VALUES
('Home Loan','Low',30),
('Car Loan','Medium',7),
('Personal Loan','High',5),
('Education Loan','Medium',15);

-- ======================
-- NUMBERS TABLE
-- ======================

CREATE TABLE numbers (n INT PRIMARY KEY);

INSERT INTO numbers (n)
SELECT a.n + b.n*10 + c.n*100 + d.n*1000 + 1
FROM 
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c,
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) d
LIMIT 50000;

-- ======================
-- INSERT CUSTOMERS (PARENT)
-- ======================

INSERT INTO customers
SELECT
    CONCAT('C', LPAD(n,5,'0')),
    CONCAT('Customer_',n),
    FLOOR(21 + RAND()*40),
    IF(n % 2 = 0, 'M', 'F'),
    FLOOR(300000 + RAND()*3000000),
    CASE 
        WHEN n % 3 = 0 THEN 'Salaried'
        WHEN n % 3 = 1 THEN 'Self-Employed'
        ELSE 'Student'
    END,
    FLOOR(550 + RAND()*300),
    ELT((n % 5)+1,'Pune','Mumbai','Delhi','Bangalore','Chennai')
FROM numbers
WHERE n <= 10000;

-- ======================
-- INSERT LOANS (FK SAFE JOIN)
-- ======================

INSERT INTO loans
SELECT
    CONCAT('L', LPAD(n.n,6,'0')),
    c.customer_id,
    CONCAT('B0', (n.n % 3)+1),
    lt.loan_type,
    FLOOR(200000 + RAND()*5000000),
    ROUND(6 + RAND()*12,2),
    FLOOR(3 + RAND()*27),
    CASE
        WHEN n.n % 15 = 0 THEN 'Default'
        WHEN n.n % 7 = 0 THEN 'Delayed'
        ELSE 'Active'
    END,
    DATE_ADD('2019-01-01', INTERVAL (n.n % 1500) DAY)
FROM numbers n
JOIN customers c
  ON c.customer_id = CONCAT('C', LPAD((n.n % 10000)+1,5,'0'))
JOIN loan_types lt
  ON lt.loan_type = CASE 
        WHEN n.n % 4 = 0 THEN 'Home Loan'
        WHEN n.n % 4 = 1 THEN 'Car Loan'
        WHEN n.n % 4 = 2 THEN 'Personal Loan'
        ELSE 'Education Loan'
     END
WHERE n.n <= 30000;

-- ======================
-- INSERT PAYMENT HISTORY (FK SAFE)
-- ======================

INSERT INTO payment_history
(loan_id, payment_date, emi_amount, paid_amount, payment_status, days_delayed)
SELECT
    l.loan_id,
    DATE_ADD('2023-01-01', INTERVAL (n.n % 365) DAY),
    FLOOR(5000 + RAND()*25000),
    CASE
        WHEN n.n % 10 = 0 THEN 0
        WHEN n.n % 6 = 0 THEN FLOOR(3000 + RAND()*8000)
        ELSE FLOOR(5000 + RAND()*25000)
    END,
    CASE
        WHEN n.n % 10 = 0 THEN 'Missed'
        WHEN n.n % 6 = 0 THEN 'Partial'
        WHEN n.n % 4 = 0 THEN 'Delayed'
        ELSE 'On-Time'
    END,
    CASE
        WHEN n.n % 10 = 0 THEN FLOOR(20 + RAND()*40)
        WHEN n.n % 4 = 0 THEN FLOOR(1 + RAND()*15)
        ELSE 0
    END
FROM numbers n
JOIN loans l
  ON l.loan_id = CONCAT('L', LPAD((n.n % 30000)+1,6,'0'))
WHERE n.n <= 120000;

-- ======================
-- INSERT FRAUD ALERTS (FK SAFE)
-- ======================

INSERT INTO fraud_alerts
(customer_id, alert_date, alert_type, risk_level)
SELECT
    c.customer_id,
    DATE_ADD('2022-01-01', INTERVAL (n.n % 500) DAY),
    CASE
        WHEN n.n % 3 = 0 THEN 'High Amount'
        WHEN n.n % 3 = 1 THEN 'Multiple Transactions'
        ELSE 'Location Mismatch'
    END,
    CASE
        WHEN n.n % 4 = 0 THEN 'High'
        WHEN n.n % 4 = 1 THEN 'Medium'
        ELSE 'Low'
    END
FROM numbers n
JOIN customers c
  ON c.customer_id = CONCAT('C', LPAD((n.n % 10000)+1,5,'0'))
WHERE n.n <= 8000;

-- ======================
-- END OF SCRIPT
-- ======================
