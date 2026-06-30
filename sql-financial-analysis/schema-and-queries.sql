-- ============================================================
-- SQL Financial Analysis Project
-- Author: Sandesh | ULM Accounting & CIS
-- Description:
--   Relational schema and analytical queries for accounting
--   use cases: AR aging, invoice variance, payment trends,
--   and ledger balance analysis.
-- ============================================================

-- ============================================================
-- SCHEMA
-- ============================================================

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    segment       VARCHAR(60),
    credit_limit  NUMERIC(12,2),
    created_at    DATE DEFAULT CURRENT_DATE
);

CREATE TABLE invoices (
    invoice_id     SERIAL PRIMARY KEY,
    customer_id    INT REFERENCES customers(customer_id),
    invoice_number VARCHAR(30) UNIQUE NOT NULL,
    invoice_date   DATE NOT NULL,
    due_date       DATE,
    amount         NUMERIC(12,2) NOT NULL,
    status         VARCHAR(20) DEFAULT 'Open', -- Open, Paid, Partial, Void
    payment_method VARCHAR(30)
);

CREATE TABLE payments (
    payment_id   SERIAL PRIMARY KEY,
    invoice_id   INT REFERENCES invoices(invoice_id),
    payment_date DATE NOT NULL,
    amount_paid  NUMERIC(12,2) NOT NULL,
    reference    VARCHAR(40)
);

CREATE TABLE gl_accounts (
    account_id   SERIAL PRIMARY KEY,
    account_code VARCHAR(20) UNIQUE NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(40) -- Asset, Liability, Revenue, Expense, Equity
);

CREATE TABLE journal_entries (
    entry_id     SERIAL PRIMARY KEY,
    entry_date   DATE NOT NULL,
    account_id   INT REFERENCES gl_accounts(account_id),
    description  VARCHAR(200),
    debit        NUMERIC(12,2) DEFAULT 0,
    credit       NUMERIC(12,2) DEFAULT 0,
    period       CHAR(7)  -- e.g. '2026-06'
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT INTO customers (customer_name, segment, credit_limit) VALUES
('Acadia Health Partners',   'Healthcare',    100000),
('Bayou Industrial Supply',  'Manufacturing',  75000),
('Crescent Retail Group',    'Retail',         50000),
('Delta Municipal Services', 'Government',    200000),
('Evergreen Medical Labs',   'Healthcare',     60000),
('Frontier Logistics',       'Logistics',      45000),
('Gulf Coast Manufacturing', 'Manufacturing', 150000),
('Harbor Energy Co.',        'Energy',         80000),
('Ivory Tech Consulting',    'Technology',     55000),
('Jefferson Community Care', 'Healthcare',     90000);

INSERT INTO invoices (customer_id, invoice_number, invoice_date, due_date, amount, status, payment_method) VALUES
(1,  'INV-1001', '2026-03-15', '2026-04-14',  18250.00, 'Paid',    'ACH'),
(1,  'INV-1002', '2026-02-08', '2026-03-10',  22400.00, 'Open',    'Check'),
(2,  'INV-1003', '2026-01-05', '2026-02-04',  31750.00, 'Open',    'Wire'),
(3,  'INV-1004', '2026-05-20', '2026-06-19',   9600.00, 'Open',    'Credit Card'),
(4,  'INV-1005', '2025-12-20', '2026-01-19',  48120.00, 'Open',    'ACH'),
(5,  'INV-1006', '2026-04-11', '2026-05-11',  14220.00, 'Paid',    'Check'),
(6,  'INV-1007', '2026-03-31', '2026-04-30',  12500.00, 'Open',    'Wire'),
(7,  'INV-1008', '2025-11-18', '2025-12-18',  59200.00, 'Open',    'ACH'),
(8,  'INV-1009', '2026-05-08', '2026-06-07',   8800.00, 'Paid',    'Credit Card'),
(9,  'INV-1010', '2026-02-01', '2026-03-03',  17110.00, 'Open',    'Check'),
(10, 'INV-1011', '2025-12-30', '2026-01-29',  26500.00, 'Open',    'ACH'),
(6,  'INV-1012', '2026-03-20', '2026-04-19',  12000.00, 'Partial', 'Wire'),
(3,  'INV-1013', '2026-05-12', '2026-06-11',  13450.00, 'Open',    'ACH'),
(4,  'INV-1014', '2026-06-12', '2026-07-12',  75000.00, 'Open',    'ACH'),
(1,  'INV-1015', '2026-06-30', '2026-06-30',    600.00, 'Open',    'ACH');

INSERT INTO payments (invoice_id, payment_date, amount_paid, reference) VALUES
(1,  '2026-06-03', 18250.00, 'RCPT-201'),
(6,  '2026-06-08', 14220.00, 'RCPT-202'),
(9,  '2026-06-15',  8800.00, 'RCPT-203'),
(12, '2026-06-21',  9600.00, 'RCPT-204-PARTIAL');

INSERT INTO gl_accounts (account_code, account_name, account_type) VALUES
('1010', 'Cash',                        'Asset'),
('1200', 'Accounts Receivable',         'Asset'),
('1500', 'Prepaid Expenses',            'Asset'),
('2010', 'Accounts Payable',            'Liability'),
('2100', 'Accrued Liabilities',         'Liability'),
('4000', 'Revenue',                     'Revenue'),
('5010', 'Salaries and Wages Expense',  'Expense'),
('5020', 'Rent Expense',                'Expense'),
('5030', 'Utilities Expense',           'Expense'),
('5040', 'Bank Fee Expense',            'Expense'),
('7010', 'Interest Income',             'Revenue'),
('3000', 'Opening Equity',              'Equity');

INSERT INTO journal_entries (entry_date, account_id, description, debit, credit, period) VALUES
('2026-06-01', 1,  'Opening cash balance',              25000.00,     0.00, '2026-06'),
('2026-06-01', 2,  'Opening AR balance',                293900.00,     0.00, '2026-06'),
('2026-06-01', 12, 'Opening equity',                         0.00, 318900.00, '2026-06'),
('2026-06-03', 1,  'Customer payment - Acadia',         18250.00,     0.00, '2026-06'),
('2026-06-03', 2,  'Customer payment - Acadia',             0.00, 18250.00, '2026-06'),
('2026-06-04', 8,  'Office rent payment',                3200.00,     0.00, '2026-06'),
('2026-06-04', 1,  'Office rent payment',                   0.00,  3200.00, '2026-06'),
('2026-06-06', 9,  'Utility payment',                     465.00,     0.00, '2026-06'),
('2026-06-06', 1,  'Utility payment',                       0.00,   465.00, '2026-06'),
('2026-06-08', 1,  'Customer payment - Evergreen',      14220.00,     0.00, '2026-06'),
('2026-06-08', 2,  'Customer payment - Evergreen',          0.00, 14220.00, '2026-06'),
('2026-06-10', 7,  'Payroll disbursement',               8750.00,     0.00, '2026-06'),
('2026-06-10', 1,  'Payroll disbursement',                   0.00,  8750.00, '2026-06'),
('2026-06-12', 2,  'June services billed - Delta',      75000.00,     0.00, '2026-06'),
('2026-06-12', 6,  'June services billed - Delta',          0.00, 75000.00, '2026-06'),
('2026-06-15', 1,  'Customer payment - Harbor',          8800.00,     0.00, '2026-06'),
('2026-06-15', 2,  'Customer payment - Harbor',             0.00,  8800.00, '2026-06'),
('2026-06-21', 1,  'Partial customer payment - Frontier', 9600.00,    0.00, '2026-06'),
('2026-06-21', 2,  'Partial customer payment - Frontier',    0.00, 9600.00, '2026-06'),
('2026-06-25', 10, 'Bank service charge',                   25.00,    0.00, '2026-06'),
('2026-06-25', 1,  'Bank service charge',                    0.00,   25.00, '2026-06'),
('2026-06-27', 1,  'Interest earned',                       18.50,    0.00, '2026-06'),
('2026-06-27', 11, 'Interest earned',                        0.00,   18.50, '2026-06'),
('2026-06-30', 2,  'NSF reversal - customer payment',      600.00,    0.00, '2026-06'),
('2026-06-30', 1,  'NSF reversal - customer payment',        0.00,  600.00, '2026-06');

-- ============================================================
-- QUERY 1: AR Aging as of a Given Date
-- ============================================================
-- Returns all open invoices with aging bucket classification.
-- Change '2026-06-30' to any as-of date.

WITH invoice_balances AS (
    SELECT
        i.invoice_id,
        i.customer_id,
        i.invoice_number,
        i.invoice_date,
        i.due_date,
        GREATEST(i.amount - COALESCE(SUM(p.amount_paid), 0), 0) AS open_balance
    FROM invoices i
    LEFT JOIN payments p ON i.invoice_id = p.invoice_id
    WHERE i.status IN ('Open', 'Partial')
    GROUP BY i.invoice_id, i.customer_id, i.invoice_number, i.invoice_date, i.due_date, i.amount
)
SELECT
    c.customer_name,
    ib.invoice_number,
    ib.invoice_date,
    ib.due_date,
    ib.open_balance,
    ('2026-06-30'::DATE - ib.due_date) AS days_past_due,
    CASE
        WHEN ib.due_date IS NULL                                    THEN 'Unknown'
        WHEN ib.due_date >= '2026-06-30'::DATE                     THEN 'Current'
        WHEN ('2026-06-30'::DATE - ib.due_date) BETWEEN 1  AND 30  THEN '1-30'
        WHEN ('2026-06-30'::DATE - ib.due_date) BETWEEN 31 AND 60  THEN '31-60'
        WHEN ('2026-06-30'::DATE - ib.due_date) BETWEEN 61 AND 90  THEN '61-90'
        WHEN ('2026-06-30'::DATE - ib.due_date) > 90               THEN '90+'
    END AS aging_bucket
FROM invoice_balances ib
JOIN customers c ON ib.customer_id = c.customer_id
WHERE ib.open_balance > 0
ORDER BY days_past_due DESC NULLS LAST;

-- ============================================================
-- QUERY 2: Customer AR Balance Summary
-- ============================================================

WITH invoice_balances AS (
    SELECT
        i.invoice_id,
        i.customer_id,
        i.due_date,
        GREATEST(i.amount - COALESCE(SUM(p.amount_paid), 0), 0) AS open_balance
    FROM invoices i
    LEFT JOIN payments p ON i.invoice_id = p.invoice_id
    WHERE i.status IN ('Open', 'Partial')
    GROUP BY i.invoice_id, i.customer_id, i.due_date, i.amount
)
SELECT
    c.customer_name,
    COUNT(ib.invoice_id)                                              AS invoice_count,
    SUM(ib.open_balance)                                              AS total_open_balance,
    SUM(CASE WHEN ib.due_date < '2026-06-30' THEN ib.open_balance
             ELSE 0 END)                                              AS overdue_balance,
    MAX('2026-06-30'::DATE - ib.due_date)                             AS max_days_past_due
FROM invoice_balances ib
JOIN customers c ON ib.customer_id = c.customer_id
WHERE ib.open_balance > 0
GROUP BY c.customer_name
ORDER BY overdue_balance DESC;

-- ============================================================
-- QUERY 3: Invoice and Payment Variance Analysis
-- ============================================================
-- Shows invoices with partial payments and the open balance.

SELECT
    c.customer_name,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    i.amount                                   AS invoice_amount,
    COALESCE(SUM(p.amount_paid), 0)            AS total_paid,
    i.amount - COALESCE(SUM(p.amount_paid), 0) AS open_balance,
    i.status
FROM invoices i
JOIN customers c    ON i.customer_id = c.customer_id
LEFT JOIN payments p ON i.invoice_id = p.invoice_id
GROUP BY c.customer_name, i.invoice_number, i.invoice_date, i.due_date, i.amount, i.status
ORDER BY open_balance DESC;

-- ============================================================
-- QUERY 4: Customers Exceeding Credit Limit
-- ============================================================

WITH invoice_balances AS (
    SELECT
        i.invoice_id,
        i.customer_id,
        GREATEST(i.amount - COALESCE(SUM(p.amount_paid), 0), 0) AS open_balance
    FROM invoices i
    LEFT JOIN payments p ON i.invoice_id = p.invoice_id
    WHERE i.status IN ('Open', 'Partial')
    GROUP BY i.invoice_id, i.customer_id, i.amount
)
SELECT
    c.customer_name,
    c.credit_limit,
    SUM(ib.open_balance) AS total_open_ar,
    SUM(ib.open_balance) - c.credit_limit AS over_limit_by
FROM invoice_balances ib
JOIN customers c ON ib.customer_id = c.customer_id
WHERE ib.open_balance > 0
GROUP BY c.customer_name, c.credit_limit
HAVING SUM(ib.open_balance) > c.credit_limit
ORDER BY over_limit_by DESC;

-- ============================================================
-- QUERY 5: GL Account Balance by Period
-- ============================================================

SELECT
    a.account_code,
    a.account_name,
    a.account_type,
    je.period,
    SUM(je.debit)  AS total_debits,
    SUM(je.credit) AS total_credits,
    SUM(je.debit) - SUM(je.credit) AS net_balance
FROM journal_entries je
JOIN gl_accounts a ON je.account_id = a.account_id
GROUP BY a.account_code, a.account_name, a.account_type, je.period
ORDER BY a.account_type, a.account_code, je.period;

-- ============================================================
-- QUERY 6: Ledger Trend — Revenue vs. Expense by Period
-- ============================================================

SELECT
    je.period,
    SUM(CASE WHEN a.account_type = 'Revenue' THEN je.credit - je.debit ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN a.account_type = 'Expense' THEN je.debit - je.credit ELSE 0 END) AS total_expense,
    SUM(CASE WHEN a.account_type = 'Revenue' THEN je.credit - je.debit ELSE 0 END)
  - SUM(CASE WHEN a.account_type = 'Expense' THEN je.debit - je.credit ELSE 0 END) AS net_income
FROM journal_entries je
JOIN gl_accounts a ON je.account_id = a.account_id
WHERE a.account_type IN ('Revenue', 'Expense')
GROUP BY je.period
ORDER BY je.period;

-- ============================================================
-- QUERY 7: Days Sales Outstanding (DSO) Calculation
-- ============================================================
-- DSO = (Total AR / Total Revenue) * Days in Period

WITH invoice_balances AS (
    SELECT
        i.invoice_id,
        GREATEST(i.amount - COALESCE(SUM(p.amount_paid), 0), 0) AS open_balance
    FROM invoices i
    LEFT JOIN payments p ON i.invoice_id = p.invoice_id
    WHERE i.status IN ('Open', 'Partial')
    GROUP BY i.invoice_id, i.amount
),
ar_total AS (
    SELECT SUM(open_balance) AS total_ar
    FROM invoice_balances
),
revenue_total AS (
    SELECT SUM(credit - debit) AS total_revenue
    FROM journal_entries je
    JOIN gl_accounts a ON je.account_id = a.account_id
    WHERE a.account_code = '4000'
      AND je.period = '2026-06'
)
SELECT
    ar.total_ar,
    rev.total_revenue,
    ROUND((ar.total_ar / NULLIF(rev.total_revenue, 0)) * 30, 1) AS dso_days
FROM ar_total ar, revenue_total rev;

-- ============================================================
-- QUERY 8: High-Risk Customer Flags
-- ============================================================
-- Customers with overdue balance > 20% of total AR.

WITH invoice_balances AS (
    SELECT
        i.invoice_id,
        i.customer_id,
        i.due_date,
        GREATEST(i.amount - COALESCE(SUM(p.amount_paid), 0), 0) AS open_balance
    FROM invoices i
    LEFT JOIN payments p ON i.invoice_id = p.invoice_id
    WHERE i.status IN ('Open', 'Partial')
    GROUP BY i.invoice_id, i.customer_id, i.due_date, i.amount
),
total_ar AS (
    SELECT SUM(open_balance) AS grand_total
    FROM invoice_balances
),
customer_ar AS (
    SELECT
        c.customer_name,
        SUM(ib.open_balance) AS customer_balance,
        SUM(CASE WHEN ib.due_date < '2026-06-30' THEN ib.open_balance ELSE 0 END) AS overdue_balance
    FROM invoice_balances ib
    JOIN customers c ON ib.customer_id = c.customer_id
    WHERE ib.open_balance > 0
    GROUP BY c.customer_name
)
SELECT
    ca.customer_name,
    ca.customer_balance,
    ca.overdue_balance,
    ROUND(ca.overdue_balance / t.grand_total * 100, 1) AS pct_of_total_ar,
    CASE WHEN ca.overdue_balance / t.grand_total > 0.20 THEN 'Concentration Risk'
         ELSE 'OK' END AS risk_flag
FROM customer_ar ca, total_ar t
WHERE ca.overdue_balance > 0
ORDER BY ca.overdue_balance DESC;
