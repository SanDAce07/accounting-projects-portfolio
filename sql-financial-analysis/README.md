# SQL Financial Analysis

SQL-based accounting and financial analysis project demonstrating practical data querying skills for AR aging, invoice variance, GL ledger analysis, and DSO calculation.

## Project Files

| File | Description |
| --- | --- |
| [schema-and-queries.sql](./schema-and-queries.sql) | Full schema + sample data + 8 analytical queries |
| [validation-tests.sql](./validation-tests.sql) | PostgreSQL assertions for journal balance, AR tie-out, aging completeness, and DSO revenue |

## Schema Overview

Five tables used in this project:

```
customers       — customer master with credit limits and segments
invoices        — invoice-level AR data with status and due dates
payments        — payment records linked to invoices
gl_accounts     — chart of accounts
journal_entries — double-entry GL transactions by period
```

## Queries Included

| # | Query | Purpose |
| --- | --- | --- |
| 1 | AR Aging as of Date | Classifies all open invoices into aging buckets |
| 2 | Customer AR Balance Summary | Summarizes open balance and overdue exposure per customer |
| 3 | Invoice and Payment Variance | Shows invoice amounts, payments applied, and open balance |
| 4 | Customers Exceeding Credit Limit | Flags customers whose remaining open AR exceeds approved credit |
| 5 | GL Account Balances by Period | Produces a trial-balance-style view from journal entries |
| 6 | Ledger Trend — Revenue vs. Expense | Calculates net income by period from GL data |
| 7 | Days Sales Outstanding (DSO) | Computes DSO from AR and revenue totals |
| 8 | High-Risk Customer Concentration | Flags customers representing >20% of total AR |

## How to Run

1. Open any SQL client (PostgreSQL, DBeaver, pgAdmin, or SQLiteOnline).
2. Run the `CREATE TABLE` and `INSERT` blocks to set up the schema and sample data.
3. Run individual queries to see results. All queries are self-contained and labeled.
4. In PostgreSQL, run `validation-tests.sql` to confirm the journal balances and the AR subledger ties to the GL.

> PostgreSQL is recommended. For SQLite, replace `SERIAL` with `INTEGER PRIMARY KEY AUTOINCREMENT`, use `DATE('2026-06-30')` instead of `'2026-06-30'::DATE`, and replace `GREATEST(value, 0)` with `MAX(value, 0)`.

## Skills Demonstrated
- Relational database design for accounting data
- AR aging logic in SQL (`CASE WHEN` bucketing)
- Aggregations with `GROUP BY`, `HAVING`, `SUM`, `COUNT`
- LEFT JOINs for invoice-to-payment variance
- CTE-based calculations (DSO, concentration risk)
- Period-based GL analysis and trend reporting
- Accounting control assertions and automated SQL validation

## Related Work
- [AR Aging Dashboard](../accounts-receivable/ar-aging-dashboard/README.md)
- [Aging Report Analyzer (Python)](https://github.com/SanDAce07/grc-audit-toolkit/blob/main/audit-scripts/aging-report-analyzer.py)
