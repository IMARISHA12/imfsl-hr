# Apache Fineract Integration — IMFSL HR

## Overview

This integration connects the IMFSL HR platform to [Apache Fineract](https://fineract.apache.org/), an open-source core banking system, replacing the previous LoanDisk integration. Data flows bi-directionally between Fineract and Supabase, with Retool providing the operational dashboard.

### Architecture

```
Apache Fineract (Core Banking)
       │
       ├── Webhooks (hooks) ──→ fineract-webhook Edge Function
       │                              │
       │                              ├── raw_fineract_* (staging)
       │                              ├── borrowers + clients (canonical)
       │                              ├── loans + loan_schedule
       │                              ├── repayments
       │                              └── savings_accounts
       │
       ├── REST API ←──────── fineract-batch-sync Edge Function
       │                              └── Full/incremental sync
       │
       ├── REST API ←──────── fineract-reconcile Edge Function
       │                              └── Variance detection
       │
       └── REST API ←──────── fineract-loan-lifecycle Edge Function
                                      └── Two-way loan operations
                                              │
                                              ▼
                                     Retool Dashboards
                                      ├── Portfolio Overview
                                      ├── Client 360
                                      ├── Loan Details
                                      ├── Collections
                                      ├── Aging/PAR Analysis
                                      └── Officer Performance
```

## Edge Functions

### 1. fineract-webhook
**Endpoint:** `POST /functions/v1/fineract-webhook`

Receives hook notifications from Fineract. Supports CLIENT, LOAN, LOAN_TRANSACTION, and SAVINGSACCOUNT entities.

**Headers:**
- `x-webhook-secret: <FINERACT_WEBHOOK_SECRET>`

**Payload format:**
```json
{
  "entity": "CLIENT",
  "action": "CREATE",
  "resourceId": 123,
  "subresourceId": null,
  "tenantIdentifier": "default",
  "body": { ... }
}
```

### 2. fineract-batch-sync
**Endpoint:** `POST /functions/v1/fineract-batch-sync`

Scheduled full/incremental sync. Pulls all entity types in dependency order:
1. Offices & Staff
2. Loan Products
3. Clients → borrowers + clients
4. Loans → loans + schedule + transactions
5. Savings Accounts

**Request body (optional):**
```json
{
  "entity_types": ["clients", "loans"],
}
```

### 3. fineract-reconcile
**Endpoint:** `POST /functions/v1/fineract-reconcile`

Compares Fineract vs local totals. Detects variances in client counts, loan amounts, outstanding balances, and repayments.

### 4. fineract-loan-lifecycle
**Endpoint:** `POST /functions/v1/fineract-loan-lifecycle`

Two-way loan operations. Executes on both Fineract and local database.

**Operations:**
```json
{"operation": "approve",    "loan_id": "uuid", "performed_by": "officer_name"}
{"operation": "disburse",   "loan_id": "uuid", "date": "2026-02-14"}
{"operation": "repayment",  "loan_id": "uuid", "amount": 500000, "payment_method": "mobile_money"}
{"operation": "writeoff",   "loan_id": "uuid", "notes": "Client relocated"}
{"operation": "close",      "loan_id": "uuid"}
{"operation": "reschedule", "loan_id": "uuid", "new_duration_months": 18}
```

## Database Schema

### New Tables
| Table | Purpose |
|-------|---------|
| `fineract_integrations` | Connection config (URL, tenant, credentials) |
| `raw_fineract_clients` | Staging for Fineract client data |
| `raw_fineract_loans` | Staging for Fineract loan data |
| `raw_fineract_transactions` | Staging for loan transactions |
| `raw_fineract_savings` | Staging for savings accounts |
| `fineract_sync_runs` | Sync execution history |
| `fineract_sync_items` | Per-entity sync tracking |
| `fineract_reconciliation_snapshots` | Reconciliation audit trail |
| `loan_products` | Fineract loan product catalog |
| `loan_schedule` | Amortization schedule per loan |
| `savings_accounts` | Client savings accounts |
| `fineract_offices` | Organization structure |
| `fineract_staff` | Staff/loan officers |
| `loan_lifecycle_events` | Loan state transition audit trail |

### Updated Columns
- `borrowers.fineract_id` — Links to Fineract client ID
- `clients.fineract_id`, `office_id`, `staff_id`, `activation_date`
- `loans.fineract_id`, `loan_product_id`, NPA/arrears fields
- `repayments.fineract_id`, transaction type, portion breakdowns

## Retool Integration

### Views (for Retool tables/charts)
| View | Purpose |
|------|---------|
| `v_portfolio_overview` | Executive KPIs (total loans, PAR%, collection rate) |
| `v_loan_officer_performance` | Per-officer metrics |
| `v_product_performance` | Per-product analytics |
| `v_aging_analysis` | PAR band breakdown (1-30, 31-60, 61-90, 91-180, 180+) |
| `v_daily_collections` | Daily collection summary with payment method breakdown |
| `v_client_360` | Comprehensive client profile with loans + savings |
| `v_loan_schedule` | Amortization schedule with installment status |
| `v_loan_audit_trail` | Loan lifecycle event history |
| `v_borrower_profiles` | Full borrower profile with loan summary |
| `v_loan_details` | Loan detail with borrower context |
| `v_repayment_history` | Repayment history with loan/borrower context |

### RPC Functions (for Retool buttons/actions)
| Function | Purpose |
|----------|---------|
| `rpc_approve_loan(loan_id, approved_by, notes)` | Approve a pending loan |
| `rpc_disburse_loan(loan_id, disbursed_by, date, notes)` | Disburse an approved loan |
| `rpc_record_repayment(loan_id, amount, method, receipt, collector, date)` | Record a repayment |
| `rpc_write_off_loan(loan_id, written_off_by, reason)` | Write off a loan |
| `rpc_reschedule_loan(loan_id, new_duration, new_rate, grace, by, reason)` | Reschedule a loan |
| `rpc_client_portfolio(client_id)` | Get full client portfolio (loans + savings + repayments) |
| `rpc_dashboard_kpis()` | Get all dashboard header KPIs in one call |

### Retool Setup Guide

1. **Connect Supabase:** Add a Supabase resource in Retool using your project URL and service role key

2. **Dashboard Page:**
   - Header KPIs: Call `rpc_dashboard_kpis()` on page load
   - Portfolio chart: Query `v_portfolio_overview`
   - Aging bands: Query `v_aging_analysis`
   - Daily collections: Query `v_daily_collections` with date filter

3. **Clients Page:**
   - Table: Query `v_client_360` with search/filter
   - Detail panel: Call `rpc_client_portfolio(client_id)` on row click
   - Risk badge: Use `risk_level` and `credit_score` fields

4. **Loans Page:**
   - Table: Query `v_loan_details` with status filter
   - Approve button: Call `rpc_approve_loan(loan_id, current_user)`
   - Disburse button: Call `rpc_disburse_loan(loan_id, current_user)`
   - Repayment form: Call `rpc_record_repayment(...)` with form inputs
   - Schedule tab: Query `v_loan_schedule` filtered by `loan_id`
   - Audit tab: Query `v_loan_audit_trail` filtered by `loan_id`

5. **Officers Page:**
   - Table: Query `v_loan_officer_performance`
   - Charts: Use collection_rate_pct, loans_in_arrears

6. **Products Page:**
   - Table: Query `v_product_performance`
   - Product catalog: Query `loan_products` table directly

## Environment Variables

```bash
# Required for Edge Functions
FINERACT_BASE_URL=https://your-fineract-instance.com
FINERACT_USERNAME=mifos
FINERACT_PASSWORD=your_password
FINERACT_TENANT_ID=default
FINERACT_WEBHOOK_SECRET=your_secret_here

# Supabase (auto-set)
SUPABASE_URL=https://lzyixazjquouicfsfzzu.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_key
```

## Deployment

```bash
# Deploy all Fineract functions
./scripts/deploy-fineract.sh

# Deploy specific function
./scripts/deploy-fineract.sh --webhook
./scripts/deploy-fineract.sh --sync
./scripts/deploy-fineract.sh --lifecycle

# Run migration
# Copy 006_fineract_integration.sql to Supabase SQL Editor and execute

# Test
./scripts/test-fineract.sh
```

## Business Logic

### Risk Assessment
- **High Risk:** Days overdue > 90, NPA flagged, or loan defaulted
- **Medium Risk:** Days overdue 31-90
- **Low Risk:** All loans current, credit score >= 70
- Score adjustments: -30 (default), -20 (90+ overdue), -10 (30+ overdue), +5 (clean payoff)

### Loan Lifecycle States
```
pending → active (approval) → active (disbursement) → completed (full repayment)
                                      ↓
                               defaulted (write-off)
                                      ↓
                               active (reschedule)
```

### PAR Classification
- **Current:** 0 days overdue
- **PAR 1-30:** 1-30 days overdue
- **PAR 31-60:** 31-60 days overdue
- **PAR 61-90:** 61-90 days overdue
- **PAR 91-180:** 91-180 days overdue
- **PAR 180+:** 180+ days overdue
- **NPA:** Non-Performing Asset (> 90 days, flagged in Fineract)

### Data Flow
1. **Webhook path:** Fineract hook → Edge Function → raw staging → canonical tables → risk update
2. **Batch sync path:** Scheduled trigger → Fineract API → paginated fetch → raw staging → canonical tables
3. **Lifecycle path:** Retool action → Edge Function → Fineract API + local DB → lifecycle event
4. **Reconciliation:** Compare Fineract totals vs local totals → snapshot with variances
