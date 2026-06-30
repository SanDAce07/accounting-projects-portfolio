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

Future dashboard ideas are listed in the repository [roadmap](../ROADMAP.md).

---

## Skills Demonstrated
- Pivot tables and pivot charts
- `XLOOKUP`, `SUMIFS`, `COUNTIFS`, `IFS`, `IFERROR`
- Conditional formatting for exception highlighting
- Dashboard design for management reporting
- Data validation and dropdown controls
- Named ranges and structured table references
