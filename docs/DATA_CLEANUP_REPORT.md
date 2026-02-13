# Data Cleanup & Integrity Report

**Date:** 2026-02-13
**Database:** IMFSL-HR Supabase (lzyixazjquouicfsfzzu)
**Migration:** `004_data_cleanup_constraints_indexes.sql`
**Scope:** 10 tables, 3 normalization functions, 4 triggers, 20+ indexes/constraints

---

## Executive Summary

Full data integrity audit across the IMFSL-HR database. **0 actual duplicate rows** found (data is clean). Key gaps identified: missing UNIQUE constraints, nullable business keys, inconsistent phone/email formats, and 3 redundant TIN columns in employees. Migration adds 20+ constraints, 4 normalization triggers, and indexes for RLS/join performance.

---

## Per-Table Analysis

### 1. STAFF (7 rows, 59 columns)

| Business Key | Current State | After Cleanup |
|-------------|--------------|---------------|
| `email` | Nullable, no UNIQUE | NOT NULL + UNIQUE(lower) + CHECK format |
| `user_id` | Nullable, no UNIQUE | UNIQUE WHERE NOT NULL |
| `phone` | Nullable, mixed format (`+255 xxx xxx xxx`) | Normalized to E.164 via trigger |
| `tin_number` | Nullable, dash format (`123-456-789`) | Normalized (dashes stripped) via trigger |

**Duplicates found:** 0
**Constraints added:** 3 (UNIQUE email, UNIQUE user_id, CHECK email format)
**Indexes added:** 2 (department, active)
**Trigger:** `trg_staff_normalize` — auto-normalizes email/phone/TIN on INSERT/UPDATE

---

### 2. EMPLOYEES (6 rows, 60 columns)

| Business Key | Current State | After Cleanup |
|-------------|--------------|---------------|
| `email` | NOT NULL, no UNIQUE | UNIQUE(lower) + CHECK format |
| `employee_code` | NOT NULL, auto-generated | UNIQUE (enforced) |
| `tin_number` | ALL NULL | Consolidated from `tin`/`tin_no`/`tin_number` |
| `tin` | ALL NULL | **DEPRECATED** — consolidated into `tin_number` |
| `tin_no` | ALL NULL | **DEPRECATED** — consolidated into `tin_number` |
| `national_id` | 1 row has value | **DEPRECATED** — consolidated into `nida_number` |
| `nida_number` | ALL NULL | Inherits from `national_id` via trigger |
| `user_id` | Nullable | UNIQUE WHERE NOT NULL |

**Duplicates found:** 0
**Field consolidation:** `tin` + `tin_no` → `tin_number`; `national_id` → `nida_number`
**Constraints added:** 5 (UNIQUE email, UNIQUE code, UNIQUE tin, UNIQUE nida, UNIQUE user_id)
**Indexes added:** 1 (dept + status composite)
**Trigger:** `trg_employees_normalize` — auto-consolidates TIN/NIDA + normalizes email/phone

**Cross-reference with STAFF:** 6/7 staff IDs match employee IDs (same UUID). "Gema Baguma" exists in staff only — may need employee record creation.

---

### 3. PROFILES (0 rows, 5 columns)

**Empty table.** Preventive constraint added: UNIQUE on phone_number WHERE NOT NULL.

---

### 4. CLIENTS (2 rows, 29 columns)

| Business Key | Current State | After Cleanup |
|-------------|--------------|---------------|
| `phone_number` | NOT NULL, local format (`0754xxx`) | Normalized to E.164 + UNIQUE + CHECK format |
| `nida_number` | 1/2 have value | UNIQUE WHERE NOT NULL |
| `external_reference_id` | 2/2 have `LD-xxx` | UNIQUE WHERE NOT NULL |

**Duplicates found:** 0 (two "Amina Hassan" entries are different people — different phone, different LD ref)
**Phone normalization:** `0754100001` → `+255754100001`, `0754999888` → `+255754999888`
**Constraints added:** 4 (UNIQUE phone, UNIQUE ext_ref, UNIQUE nida, CHECK phone format)
**Indexes added:** 1 (status + risk_level)
**Trigger:** `trg_clients_normalize` — auto-normalizes phone on INSERT/UPDATE

---

### 5. CUSTOMERS (2 rows, 15 columns)

| Business Key | Current State | After Cleanup |
|-------------|--------------|---------------|
| `customer_code` | NOT NULL, unique values | UNIQUE (enforced) |
| `email` | 2/2 have values | UNIQUE(lower) WHERE NOT NULL |
| `phone` | 2/2, E.164 format already | UNIQUE WHERE NOT NULL |

**Duplicates found:** 0
**Constraints added:** 3 (UNIQUE code, UNIQUE email, UNIQUE phone)

---

### 6. VENDORS (5 rows, 15 columns)

| Business Key | Current State | After Cleanup |
|-------------|--------------|---------------|
| `vendor_code` | ALL NULL (5/5) | Auto-generated `VND-0001`..`VND-0005` + NOT NULL + UNIQUE |
| `vendor_name` | 5 unique values | UNIQUE(lower) |

**Duplicates found:** 0
**Data fixed:** 5 vendor codes generated (were all NULL)
**Constraints added:** 2 (UNIQUE code, UNIQUE name) + NOT NULL on vendor_code

---

### 7. BORROWERS (10 rows, 8 columns)

| Business Key | Current State | After Cleanup |
|-------------|--------------|---------------|
| `phone_number` | NOT NULL | Normalized E.164 + UNIQUE |
| `nida_number` | Nullable | UNIQUE WHERE NOT NULL |

**Constraints added:** 2 (UNIQUE phone, UNIQUE nida)

---

### 8. LOANS (10 rows, 19 columns)

| Business Key | Current State | After Cleanup |
|-------------|--------------|---------------|
| `loan_number` | Nullable | UNIQUE WHERE NOT NULL |
| `borrower_id` | NOT NULL (FK) | Indexed with status |

**Constraints added:** 1 (UNIQUE loan_number)
**Indexes added:** 2 (borrower_id + status, officer_id)

---

### 9. LEAVE BALANCES (28 rows, 9 columns)

**Constraint added:** UNIQUE on (staff_id, leave_type, year) — prevents duplicate balances per type per year.

---

### 10. ATTENDANCE RECORDS (15 rows, 15 columns)

**Existing constraint:** `unique_staff_work_date` on (staff_id, work_date) — already correct.
**Indexes added:** 2 (work_date for reports, staff_id for per-staff queries)

---

## Summary of Changes

### Normalization Functions Created

| Function | Purpose | Used By |
|----------|---------|---------|
| `normalize_email(text)` | `lower(trim(x))` | staff, employees |
| `normalize_phone_tz(text)` | Tanzania E.164: `0712xxx` → `+255712xxx` | staff, employees, clients, borrowers |
| `normalize_tin(text)` | Strip dashes/spaces, uppercase | staff, employees |

### Triggers Created

| Trigger | Table | Fires On | Actions |
|---------|-------|----------|---------|
| `trg_staff_normalize` | staff | BEFORE INSERT/UPDATE | Normalize email, phone, TIN |
| `trg_employees_normalize` | employees | BEFORE INSERT/UPDATE | Normalize email, phone; consolidate TIN/NIDA |
| `trg_clients_normalize` | clients | BEFORE INSERT/UPDATE | Normalize phone to E.164 |
| `trg_borrowers_normalize` | borrowers | BEFORE INSERT/UPDATE | Normalize phone to E.164 |

### Constraints Added

| Table | Constraint | Type | Risk |
|-------|-----------|------|------|
| staff | `idx_staff_email_unique` | UNIQUE(lower(email)) | None (0 dups) |
| staff | `idx_staff_user_id_unique` | UNIQUE(user_id) partial | None (0 dups) |
| staff | `chk_staff_email_format` | CHECK regex | None (all valid) |
| employees | `idx_employees_email_unique` | UNIQUE(lower(email)) | None (0 dups) |
| employees | `idx_employees_code_unique` | UNIQUE(employee_code) | None (0 dups) |
| employees | `idx_employees_tin_unique` | UNIQUE(normalize_tin(tin_number)) partial | None (all NULL) |
| employees | `idx_employees_nida_unique` | UNIQUE(nida_number) partial | None (1 unique) |
| employees | `idx_employees_user_id_unique` | UNIQUE(user_id) partial | None (0 dups) |
| employees | `chk_employees_email_format` | CHECK regex | None (all valid) |
| clients | `idx_clients_phone_unique` | UNIQUE(phone_number) | None (0 dups) |
| clients | `idx_clients_ext_ref_unique` | UNIQUE(external_reference_id) partial | None (0 dups) |
| clients | `idx_clients_nida_unique` | UNIQUE(nida_number) partial | None (0 dups) |
| clients | `chk_clients_phone_format` | CHECK regex (TZ E.164) | Verify after normalize |
| customers | `idx_customers_code_unique` | UNIQUE(customer_code) | None (0 dups) |
| customers | `idx_customers_email_unique` | UNIQUE(lower(email)) partial | None (0 dups) |
| customers | `idx_customers_phone_unique` | UNIQUE(phone) partial | None (0 dups) |
| vendors | `idx_vendors_code_unique` | UNIQUE(vendor_code) | None (codes generated) |
| vendors | `idx_vendors_name_unique` | UNIQUE(lower(vendor_name)) | None (0 dups) |
| borrowers | `idx_borrowers_phone_unique` | UNIQUE(phone_number) | Verify no dups |
| borrowers | `idx_borrowers_nida_unique` | UNIQUE(nida_number) partial | None |
| loans | `idx_loans_number_unique` | UNIQUE(loan_number) partial | Verify no dups |
| leave_balances | `idx_leave_balances_key` | UNIQUE(staff_id, leave_type, year) | Verify no dups |

### Indexes Added (Performance)

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| staff | `idx_staff_department` | department | RLS, filters |
| staff | `idx_staff_active` | active | Status filters |
| employees | `idx_employees_dept_status` | dept, status | Common query |
| clients | `idx_clients_status_risk` | status, risk_level | Risk queries |
| loans | `idx_loans_borrower_status` | borrower_id, status | Join + filter |
| loans | `idx_loans_officer` | officer_id | Officer queries |
| attendance | `idx_attendance_work_date` | work_date | Reports |
| attendance | `idx_attendance_staff_id` | staff_id | Per-staff queries |

### Deprecated Columns (Marked, Not Dropped)

| Table | Column | Replacement | Action |
|-------|--------|------------|--------|
| employees | `tin` | `tin_number` | COMMENT 'DEPRECATED' |
| employees | `tin_no` | `tin_number` | COMMENT 'DEPRECATED' |
| employees | `national_id` | `nida_number` | COMMENT 'DEPRECATED' |

---

## Application Layer Recommendations

1. **Upsert patterns:** Use `INSERT ... ON CONFLICT (business_key) DO UPDATE` instead of check-then-insert
2. **Email normalization:** Call `normalize_email()` or just `lower(trim())` before comparisons
3. **Phone input:** Accept any Tanzania format; triggers normalize to E.164 automatically
4. **TIN fields:** Stop writing to `tin` or `tin_no`; use `tin_number` exclusively
5. **National ID:** Stop writing to `national_id`; use `nida_number` exclusively
6. **Vendor creation:** `vendor_code` is now NOT NULL + UNIQUE — provide it or let DB generate

---

*End of Report*
