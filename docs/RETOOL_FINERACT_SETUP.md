# Retool + Fineract + Supabase — Connection Guide

## Architecture

```
Retool Dashboard
  ├── Supabase Resource (existing)
  │     ├── Views: v_portfolio_overview, v_client_360, v_aging_analysis, ...
  │     ├── RPC:   rpc_approve_loan, rpc_record_repayment, rpc_dashboard_kpis, ...
  │     └── Tables: borrowers, loans, repayments, clients, ...
  │
  ├── Fineract REST API Resource (new)
  │     ├── Direct API calls to Fineract for real-time operations
  │     └── Used for: client search, loan details, schedule preview
  │
  └── Supabase Edge Functions (new)
        ├── fineract-loan-lifecycle: Two-way operations
        ├── fineract-batch-sync: Data sync trigger
        └── fineract-reconcile: Variance check
```

## Step 1: Add Fineract as a REST API Resource in Retool

1. Go to **Retool → Resources → Create Resource → REST API**
2. Configure:
   - **Name:** `Fineract`
   - **Base URL:** `https://your-fineract-instance.com/fineract-provider/api/v1`
   - **Authentication:** Basic Auth
     - Username: `mifos`
     - Password: `(your password)`
   - **Headers:**
     - `Fineract-Platform-TenantId`: `default`
     - `Content-Type`: `application/json`
3. Click **Test Connection** then **Save**

## Step 2: Add Edge Functions as a REST API Resource

1. Go to **Retool → Resources → Create Resource → REST API**
2. Configure:
   - **Name:** `IMFSL Edge Functions`
   - **Base URL:** `https://lzyixazjquouicfsfzzu.supabase.co/functions/v1`
   - **Headers:**
     - `x-webhook-secret`: `(your FINERACT_WEBHOOK_SECRET)`
     - `Content-Type`: `application/json`
3. Save

## Step 3: Build Dashboard Pages

### 3a. Executive Dashboard

**Data Sources (on page load):**
```
Query 1: Supabase → rpc_dashboard_kpis()
Query 2: Supabase → SELECT * FROM v_portfolio_overview
Query 3: Supabase → SELECT * FROM v_aging_analysis
Query 4: Supabase → SELECT * FROM v_daily_collections WHERE collection_date >= current_date - 30
```

**Components:**
- Stat cards: total_clients, active_loans, total_outstanding, collection_rate_pct
- Pie chart: aging bands from v_aging_analysis
- Line chart: daily collections trend
- Table: v_loan_officer_performance

### 3b. Clients Page

**Data Sources:**
```
Query: Supabase → SELECT * FROM v_client_360 WHERE status = 'active' ORDER BY full_name
Detail: Supabase → rpc_client_portfolio({{ clientTable.selectedRow.client_id }})
```

**Components:**
- Searchable table with client list
- Detail panel showing loans, savings, recent repayments
- Risk badge (color by risk_level: green=Low, yellow=Medium, red=High)

### 3c. Loans Page

**Data Sources:**
```
Loans: Supabase → SELECT * FROM v_loan_details WHERE status = {{ statusFilter.value }}
Schedule: Supabase → SELECT * FROM v_loan_schedule WHERE loan_id = {{ loansTable.selectedRow.id }}
Audit: Supabase → SELECT * FROM v_loan_audit_trail WHERE loan_id = {{ loansTable.selectedRow.id }}
```

**Action Buttons:**

**Approve Loan:**
```
Resource: IMFSL Edge Functions
Method: POST
URL: /fineract-loan-lifecycle
Body: {
  "operation": "approve",
  "loan_id": {{ loansTable.selectedRow.id }},
  "performed_by": {{ current_user.email }},
  "notes": {{ approveNotes.value }}
}
```

**Disburse Loan:**
```
Resource: IMFSL Edge Functions
Method: POST
URL: /fineract-loan-lifecycle
Body: {
  "operation": "disburse",
  "loan_id": {{ loansTable.selectedRow.id }},
  "performed_by": {{ current_user.email }},
  "date": {{ disburseDatePicker.value }}
}
```

**Record Repayment:**
```
Resource: IMFSL Edge Functions
Method: POST
URL: /fineract-loan-lifecycle
Body: {
  "operation": "repayment",
  "loan_id": {{ loansTable.selectedRow.id }},
  "amount": {{ repaymentAmount.value }},
  "payment_method": {{ paymentMethodSelect.value }},
  "receipt_ref": {{ receiptInput.value }},
  "performed_by": {{ current_user.email }},
  "date": {{ paymentDatePicker.value }}
}
```

**Write Off Loan:**
```
Resource: IMFSL Edge Functions
Method: POST
URL: /fineract-loan-lifecycle
Body: {
  "operation": "writeoff",
  "loan_id": {{ loansTable.selectedRow.id }},
  "performed_by": {{ current_user.email }},
  "notes": {{ writeoffReason.value }}
}
```

### 3d. Collections Page

**Data Sources:**
```
Today: Supabase → SELECT * FROM v_daily_collections WHERE collection_date = current_date
History: Supabase → SELECT * FROM v_repayment_history ORDER BY paid_at DESC LIMIT 100
```

### 3e. Products Page

**Data Sources:**
```
Products: Supabase → SELECT * FROM v_product_performance
Catalog: Supabase → SELECT * FROM loan_products WHERE is_active = true
```

### 3f. Sync & Admin Page

**Trigger Batch Sync:**
```
Resource: IMFSL Edge Functions
Method: POST
URL: /fineract-batch-sync
Body: {
  "entity_types": ["clients", "loans", "transactions"]
}
```

**Trigger Reconciliation:**
```
Resource: IMFSL Edge Functions
Method: POST
URL: /fineract-reconcile
Body: {}
```

**Sync History:**
```
Supabase → SELECT * FROM fineract_sync_runs ORDER BY started_at DESC LIMIT 20
```

**Direct Fineract Queries (optional):**
```
Resource: Fineract
Method: GET
URL: /clients?limit=10&displayName={{ searchInput.value }}
```

## Step 4: Direct Fineract API Queries (Advanced)

You can also query Fineract directly from Retool for real-time data:

**Search Clients:**
```
Resource: Fineract
GET /clients?displayName={{ search }}&limit=20
```

**Get Loan Details with Schedule:**
```
Resource: Fineract
GET /loans/{{ loanId }}?associations=all
```

**Get Client Accounts:**
```
Resource: Fineract
GET /clients/{{ clientId }}/accounts
```

**Get Loan Products:**
```
Resource: Fineract
GET /loanproducts
```

## RPC Functions Reference

| Function | Input | Output | Use In Retool |
|----------|-------|--------|--------------|
| `rpc_dashboard_kpis()` | none | JSON with all KPIs | Dashboard header stats |
| `rpc_client_portfolio(client_id)` | UUID | loans, savings, repayments | Client detail panel |
| `rpc_approve_loan(loan_id, by, notes)` | UUID, text, text | success/error | Approve button |
| `rpc_disburse_loan(loan_id, by, date)` | UUID, text, date | success/error | Disburse button |
| `rpc_record_repayment(loan_id, amount, method, receipt, collector, date)` | UUID, numeric, text... | repayment details | Repayment form |
| `rpc_write_off_loan(loan_id, by, reason)` | UUID, text, text | success/error | Write-off button |
| `rpc_reschedule_loan(loan_id, months, rate, grace, by, reason)` | UUID, int, numeric... | success/error | Reschedule form |
