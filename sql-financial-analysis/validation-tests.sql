-- Run after schema-and-queries.sql in PostgreSQL.
-- Each block raises an exception when an accounting control fails.

DO $$
DECLARE
    total_debits  NUMERIC(14,2);
    total_credits NUMERIC(14,2);
BEGIN
    SELECT SUM(debit), SUM(credit)
    INTO total_debits, total_credits
    FROM journal_entries
    WHERE period = '2026-06';

    IF total_debits <> total_credits THEN
        RAISE EXCEPTION 'Journal is out of balance: debits %, credits %', total_debits, total_credits;
    END IF;
END $$;

DO $$
DECLARE
    subledger_ar NUMERIC(14,2);
    ledger_ar    NUMERIC(14,2);
BEGIN
    WITH invoice_balances AS (
        SELECT
            i.invoice_id,
            GREATEST(i.amount - COALESCE(SUM(p.amount_paid), 0), 0) AS open_balance
        FROM invoices i
        LEFT JOIN payments p ON i.invoice_id = p.invoice_id
        WHERE i.status IN ('Open', 'Partial')
        GROUP BY i.invoice_id, i.amount
    )
    SELECT SUM(open_balance) INTO subledger_ar
    FROM invoice_balances;

    SELECT SUM(je.debit - je.credit) INTO ledger_ar
    FROM journal_entries je
    JOIN gl_accounts a ON je.account_id = a.account_id
    WHERE a.account_code = '1200';

    IF subledger_ar <> ledger_ar THEN
        RAISE EXCEPTION 'AR subledger does not tie to GL: subledger %, ledger %', subledger_ar, ledger_ar;
    END IF;
END $$;

DO $$
DECLARE
    unclassified_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO unclassified_count
    FROM (
        SELECT CASE
            WHEN due_date IS NULL THEN 'Unknown'
            WHEN due_date >= '2026-06-30'::DATE THEN 'Current'
            WHEN ('2026-06-30'::DATE - due_date) BETWEEN 1 AND 30 THEN '1-30'
            WHEN ('2026-06-30'::DATE - due_date) BETWEEN 31 AND 60 THEN '31-60'
            WHEN ('2026-06-30'::DATE - due_date) BETWEEN 61 AND 90 THEN '61-90'
            WHEN ('2026-06-30'::DATE - due_date) > 90 THEN '90+'
        END AS aging_bucket
        FROM invoices
        WHERE status IN ('Open', 'Partial')
    ) aged
    WHERE aging_bucket IS NULL;

    IF unclassified_count <> 0 THEN
        RAISE EXCEPTION '% open invoices have no aging bucket', unclassified_count;
    END IF;
END $$;

DO $$
DECLARE
    operating_revenue NUMERIC(14,2);
BEGIN
    SELECT SUM(je.credit - je.debit) INTO operating_revenue
    FROM journal_entries je
    JOIN gl_accounts a ON je.account_id = a.account_id
    WHERE a.account_code = '4000'
      AND je.period = '2026-06';

    IF operating_revenue IS NULL OR operating_revenue <= 0 THEN
        RAISE EXCEPTION 'Operating revenue must be positive for DSO; found %', operating_revenue;
    END IF;
END $$;
