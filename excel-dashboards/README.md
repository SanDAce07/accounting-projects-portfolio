# Excel Dashboards

Excel-based financial analysis and management reporting projects demonstrating pivot table design, formula logic, and accounting-relevant dashboard builds.

## Projects

### AR Aging Dashboard
Built in the [ar-aging-dashboard](../accounts-receivable/ar-aging-dashboard/README.md) project. An invoice-level aging tracker with:
- Aging bucket classification (`Current`, `1-30`, `31-60`, `61-90`, `90+`)
- Customer-level overdue concentration summary
- Exception flagging for credit balances and missing due dates
- Dashboard-ready summary metrics

**Key formulas used:**
- `=MAX(0, TODAY()-due_date)` for days past due
- Nested `IFS()` for aging bucket assignment
- `SUMIFS()` for customer and bucket summaries
- Pivot tables for cross-tab aging analysis

---

### Bank Reconciliation Workbook
Built in the [bank-reconciliation-analyzer](../accounts-receivable/bank-reconciliation-analyzer/README.md) project. A workbook covering:
- Book-side and bank-side transaction registers
- Matched transaction log with match basis notation
- Reconciling items schedule (timing differences vs. book adjustments)
- Adjusted cash summary tying both sides to a common balance
- Journal entry support for bank-only items

---

### Planned: Month-End Close Tracker
An Excel dashboard for tracking close tasks by day, owner, and status, with:
- Color-coded status indicators (Not Started / In Progress / Complete)
- Weighted completion % progress bar
- Open items rollforward section

---

### Planned: AP / AR KPI Dashboard
A management-facing KPI dashboard including:
- DSO (Days Sales Outstanding)
- DPO (Days Payable Outstanding)
- Collection effectiveness ratio
- Overdue AR concentration chart
- Period-over-period trend sparklines

---

## Skills Demonstrated
- Pivot tables and pivot charts
- `XLOOKUP`, `SUMIFS`, `COUNTIFS`, `IFS`, `IFERROR`
- Conditional formatting for exception highlighting
- Dashboard design for management reporting
- Data validation and dropdown controls
- Named ranges and structured table references
