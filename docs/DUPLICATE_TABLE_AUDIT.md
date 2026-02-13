# Duplicate Table Audit Report

**Date:** 2026-02-13
**Database:** IMFSL-HR Supabase (lzyixazjquouicfsfzzu)
**Total Tables/Views/RPCs:** 1,204
**Auditor:** Automated Engineering Audit

---

## Executive Summary

The IMFSL-HR database contains **1,204 objects** (tables, views, materialized views, RPCs). A systematic audit identified **47 tables** that are duplicated, overlapping, or superseded across 9 functional domains. Of these, **18 tables are empty and unreferenced** — safe candidates for immediate deprecation. An additional **73 z_archive_ tables** exist as historical backups with no active code references.

---

## 1. LoanDisk Pipeline (CRITICAL)

### Architecture

The active LoanDisk integration follows a 3-layer pipeline:

```
LoanDisk API → raw_* (staging) → canonical tables → clients (enriched)
```

| Layer | Active Tables | Status |
|-------|--------------|--------|
| Staging | `raw_borrowers`, `raw_loans`, `raw_repayments` | ACTIVE — used by all Edge Functions |
| Canonical | `borrowers`, `loans`, `repayments` | ACTIVE — primary business tables |
| Enriched | `clients` | ACTIVE — enriched client profiles |
| Sync Control | `loandisk_sync_runs`, `loandisk_sync_items` | ACTIVE — sync orchestration |
| Config | `loandisk_integrations` | ACTIVE — API credentials |

### Duplicate Tables (DEPRECATED — Zero Code References)

| Table | Rows | Columns | Overlap With | Recommendation |
|-------|------|---------|--------------|----------------|
| `ld_borrowers` | 0 | 26 | `raw_borrowers` + `borrowers` | **DROP** — legacy schema, never populated |
| `ld_loans` | 0 | 26 | `raw_loans` + `loans` | **DROP** — legacy schema, never populated |
| `ld_repayments` | 0 | 17 | `raw_repayments` + `repayments` | **DROP** — legacy schema, never populated |
| `fin_borrowers` | 0 | 10 | `borrowers` | **DROP** — unused finance module stub |
| `fin_loans` | 0 | 15 | `loans` | **DROP** — unused finance module stub |
| `staging_loans_import` | 0 | 11 | `raw_loans` | **DROP** — superseded by raw_loans pipeline |
| `sync_runs` | 0 | 13 | `loandisk_sync_runs` | **DROP** — superseded by loandisk_sync_runs |
| `customer_loans` | 0 | 12 | `loans` | **DROP** — unused alternate schema |
| `customers_core` | 0 | 10 | `clients` | **DROP** — unused alternate schema |

**Analysis:** The `ld_*` tables appear to be from an earlier LoanDisk integration attempt that pre-parsed JSON into normalized columns. The current architecture correctly uses `raw_*` tables with JSONB `payload` for staging, then transforms into canonical tables. The `ld_*` approach was abandoned before any data was loaded.

---

## 2. Attendance Module

| Table | Rows | Columns | Purpose |
|-------|------|---------|---------|
| `attendance` | 13 | 13 | Original attendance with GPS + approval |
| `attendance_v2` | 0 | 5 | Simplified v2 attempt — **never populated** |
| `attendance_records` | 15 | 15 | Manager-rated attendance records |
| `staff_attendance_v3` | 0 | 29 | Full biometric/geofence v3 — **never populated** |

**Recommendation:**
- **DROP** `attendance_v2` (0 rows, 5 cols, superseded)
- **KEEP** `attendance` (active, has data)
- **KEEP** `attendance_records` (active, has data, different purpose — manager reviews)
- **EVALUATE** `staff_attendance_v3` — comprehensive schema designed for geofence/biometric but never deployed. Keep if deployment is planned; drop if abandoned.

---

## 3. Audit Logging

| Table | Rows | Columns | Purpose |
|-------|------|---------|---------|
| `audit_logs` | 143 | 8 | Primary audit trail — **ACTIVE** |
| `audit_logs_new` | 2 | 9 | Replacement attempt with IP tracking — barely used |
| `security_audit_logs` | 18 | — | Security-specific audit events |
| `system_audit_logs` | 32 | — | System-level audit events |
| `access_logs` | 44 | — | Resource access tracking |

**Recommendation:**
- **KEEP** `audit_logs` as primary
- **EVALUATE** `audit_logs_new` — if the IP address column is needed, add it to `audit_logs` and migrate 2 rows; then **DROP**
- **KEEP** `security_audit_logs`, `system_audit_logs`, `access_logs` — these serve distinct security domains

---

## 4. Leave Management

| Table | Rows | Columns | Purpose |
|-------|------|---------|---------|
| `leave_balance` | 0 | 13 | Static column-per-type balance design |
| `leave_balances` | 28 | 9 | Normalized row-per-type balance — **ACTIVE** |
| `leave_policy` | 5 | 13 | Basic policy rules |
| `leave_policies` | 6 | 17 | Enhanced policy with legal references — **ACTIVE** |

**Recommendation:**
- **DROP** `leave_balance` (0 rows, rigid column-per-type design superseded by normalized `leave_balances`)
- **EVALUATE** `leave_policy` vs `leave_policies` — both have data. `leave_policies` is richer (17 cols vs 13, includes `legal_reference`, `imfsl_policy_reference`). Migrate the 5 rows from `leave_policy` → `leave_policies`, then **DROP** `leave_policy`.

---

## 5. Petty Cash

| Table | Rows | Columns | Purpose |
|-------|------|---------|---------|
| `petty_cash` | 0 | 8 | Simple request-based petty cash — **UNUSED** |
| `petty_cash_boxes` | 3 | 10 | Physical cash box tracking — **ACTIVE** |
| `petty_cash_registers` | 3 | 6 | Branch-level register — **ACTIVE** |

**Recommendation:**
- **DROP** `petty_cash` (0 rows, superseded by the boxes/registers/vouchers system)
- **KEEP** `petty_cash_boxes`, `petty_cash_registers`, `petty_cash_vouchers`, `petty_cash_transactions`, `petty_cash_requests`

---

## 6. Journal / General Ledger

| Table | Rows | Columns | Purpose |
|-------|------|---------|---------|
| `journal_entries` | 0 | 21 | QBO-integrated journal — **UNUSED** |
| `journal_entry_lines` | 0 | 9 | Lines for QBO journals — **UNUSED** |
| `journals` | 1 | 14 | Simpler journal system — **ACTIVE** |
| `journal_lines` | 2 | 11 | Lines for simple journals — **ACTIVE** |

**Recommendation:**
- **EVALUATE** `journal_entries` / `journal_entry_lines` — these have QBO (QuickBooks Online) integration fields (`qbo_id`, `qbo_sync_token`, `qbo_doc_number`). If QBO integration is planned, **KEEP**. If abandoned, **DROP**.
- **KEEP** `journals` + `journal_lines` as the active GL system.

---

## 7. Roles & Permissions

| Table | Rows | Purpose |
|-------|------|---------|
| `roles` | 21 | Core role definitions — **ACTIVE** |
| `permissions` | 0 | Generic permission keys — **UNUSED** |
| `role_permissions` | 0 | Role→permission mapping — **UNUSED** |
| `app_roles` | 4 | Application-level roles — **ACTIVE** |
| `operational_roles` | 12 | Operational role types — **ACTIVE** |
| `user_roles` | 13 | User→role assignments — **ACTIVE** |
| `enterprise_permissions` | 49 | Enterprise permission defs — **ACTIVE** |
| `role_enterprise_permissions` | 116 | Enterprise role→perm mapping — **ACTIVE** |
| `user_governance_roles` | 20 | Governance role assignments — **ACTIVE** |
| `staff_roles` | 0 | Staff-specific roles — **UNUSED** |
| `staff_permissions` | 0 | Staff-specific permissions — **UNUSED** |

**Recommendation:**
- **DROP** `permissions`, `role_permissions` (0 rows, superseded by `enterprise_permissions` + `role_enterprise_permissions`)
- **DROP** `staff_roles`, `staff_permissions` (0 rows, never used)
- **KEEP** all other tables — they serve distinct active functions

---

## 8. Archive Tables (z_archive_*)

**73 tables** prefixed with `z_archive_` exist. These are historical backups from schema migrations. **Zero active code references** found across all Edge Functions, Dart models, and scripts.

**Recommendation:** **DROP ALL** z_archive_ tables in a single batch migration. They are dead weight consuming storage and cluttering the schema.

---

## Summary Matrix

| Category | Tables to DROP | Tables to EVALUATE | Rows at Risk | Estimated Storage Freed |
|----------|---------------|-------------------|-------------|------------------------|
| LoanDisk Duplicates | 9 | 0 | 0 | Low (empty tables) |
| Attendance | 1–2 | 1 | 0 | Low |
| Audit Logs | 0–1 | 1 | 2 | Low |
| Leave Management | 1–2 | 1 | 5 | Low |
| Petty Cash | 1 | 0 | 0 | Low |
| Journals | 0–2 | 2 | 0 | Low |
| Roles/Permissions | 4 | 0 | 0 | Low |
| z_archive_ | 73 | 0 | varies | Medium |
| **TOTAL** | **89–92** | **5** | **7** | **Medium** |

---

## Migration Strategy

### Phase 1: Safe Drops (Zero Data, Zero References)
Drop 18 empty, unreferenced tables immediately:
- `ld_borrowers`, `ld_loans`, `ld_repayments`
- `fin_borrowers`, `fin_loans`
- `sync_runs`, `staging_loans_import`, `customer_loans`, `customers_core`
- `attendance_v2`, `staff_attendance_v3`
- `leave_balance`
- `petty_cash`
- `permissions`, `role_permissions`, `staff_roles`, `staff_permissions`
- `loan_repayments` (0 rows, superseded by `repayments`)

### Phase 2: Archive Cleanup
Drop all 73 `z_archive_*` tables.

### Phase 3: Consolidation (Requires Data Migration)
- Merge `leave_policy` → `leave_policies` (5 rows)
- Merge `audit_logs_new` → `audit_logs` (2 rows, add ip_address column)
- Evaluate `journal_entries` / `journal_entry_lines` QBO integration status

---

*End of Report*
