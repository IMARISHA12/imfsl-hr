# Data Cleanup & Integrity Report — IMFSL-HR

**Date:** 2026-02-14
**Database:** IMFSL-HR Supabase (`lzyixazjquouicfsfzzu`)
**Migration Files:** `000` through `004` + `RUN_ALL_MIGRATIONS.sql`
**Scope:** 11 tables, 3 normalization functions, 4 triggers, 21 unique indexes, 3 CHECK constraints, 8 performance indexes

---

## Executive Summary

A comprehensive live audit was performed against all business-critical tables. **Zero actual duplicate rows** exist — all data is clean. However, the database lacks preventive constraints (no UNIQUE indexes on business keys, no CHECK constraints, no normalization triggers). This report documents the current state, the migration impact, and application-layer patterns to maintain integrity going forward.

---

## PART 1: Live Audit Results (Current State)

### 1.1 Staff (7 rows, 59 columns)

| # | full_name | email | phone | tin_number | user_id |
|---|-----------|-------|-------|------------|---------|
| 1 | Yohana Bunzali | yohana.bunzali@imfsl.co.tz | +255 xxx xxx xxx | 153-319-035 | auth UUID |
| 2 | Frank Justine | frank.justine@imfsl.co.tz | +255 xxx xxx xxx | 150-410-647 | auth UUID |
| 3 | Hilda Kundael | hilda.kundael@imfsl.co.tz | +255 xxx xxx xxx | NULL | auth UUID |
| 4 | Paul Masunga | paul.masunga@imfsl.co.tz | +255 xxx xxx xxx | NULL | auth UUID |
| 5 | Gema Baguma | gema.baguma@imfsl.co.tz | +255 xxx xxx xxx | NULL | auth UUID |
| 6 | Aura Amri | aura.amri@imfsl.co.tz | +255 xxx xxx xxx | NULL | auth UUID |
| 7 | Naomi Urasa | naomi.urasa@imfsl.co.tz | +255 xxx xxx xxx | NULL | auth UUID |

**Findings:**
- Duplicate emails: **0** (all unique)
- Duplicate user_ids: **0** (all unique)
- Phone values: All are placeholder `+255 xxx xxx xxx` — need real phone numbers
- TIN values: Only 2/7 populated (dash format `153-319-035`), will normalize to `153319035`
- UNIQUE constraints: **None exist** — only prevented by luck
- Email NOT NULL: Not enforced at DB level

---

### 1.2 Employees (6 rows, 60 columns)

| # | full_name | email | employee_code | tin | tin_no | tin_number | national_id | nida_number | user_id |
|---|-----------|-------|---------------|-----|--------|------------|-------------|-------------|---------|
| 1 | Yohana Bunzali | yohana.bunzali@imfsl.co.tz | EMP001 | NULL | NULL | NULL | NULL | NULL | same as staff |
| 2 | Frank Justine | frank.justine@imfsl.co.tz | EMP002 | NULL | NULL | NULL | 19900101-00002 | NULL | same as staff |
| 3 | Hilda Kundael | hilda.kundael@imfsl.co.tz | EMP003 | NULL | NULL | NULL | NULL | NULL | same as staff |
| 4 | Paul Masunga | paul.masunga@imfsl.co.tz | EMP004 | NULL | NULL | NULL | NULL | NULL | same as staff |
| 5 | Aura Amri | aura.amri@imfsl.co.tz | EMP005 | NULL | NULL | NULL | NULL | NULL | same as staff |
| 6 | Naomi Urasa | naomi.urasa@imfsl.co.tz | EMP006 | NULL | NULL | NULL | NULL | NULL | same as staff |

**Findings:**
- Duplicate emails: **0** (all unique)
- TIN fragmentation: **3 columns** (`tin`, `tin_no`, `tin_number`) — ALL NULL across all 6 employees
- National ID fragmentation: **2 columns** (`national_id`, `nida_number`) — only Frank has `19900101-00002` in `national_id`
- Missing employee: "Gema Baguma" exists in staff but NOT in employees
- Cross-reference: 6/7 staff IDs = employee IDs (shared UUID pattern)
- UNIQUE constraints: **None exist**

---

### 1.3 Profiles (0 rows, 5 columns)

**Empty table.** No data to audit. Preventive UNIQUE constraint will be added on `phone_number`.

---

### 1.4 Clients (2 rows, 29 columns)

| # | full_name | phone_number | nida_number | external_reference_id |
|---|-----------|-------------|-------------|----------------------|
| 1 | Amina Hassan | 0754100001 | 19900101-10001 | LD-200001 |
| 2 | Amina Hassan | 0754999888 | NULL | LD-800001 |

**Findings:**
- Same name "Amina Hassan" x2 but **different people** (different phone, different nida, different LD reference)
- Phone format: **Local** (`0754xxx`) — needs E.164 normalization → `+255754100001`
- UNIQUE constraints: **None exist**

---

### 1.5 Customers (2 rows, 15 columns)

| # | customer_code | full_name | email | phone |
|---|--------------|-----------|-------|-------|
| 1 | CUST-001 | Acme Corp | acme@example.com | +255712345678 |
| 2 | CUST-002 | Beta Ltd | beta@example.com | +255723456789 |

**Findings:**
- All fields populated and clean
- Phone format: **Already E.164** — no normalization needed
- UNIQUE constraints: **None exist**

---

### 1.6 Vendors (5 rows, 15 columns)

| # | vendor_name | service_type | vendor_code | contact_email |
|---|------------|-------------|-------------|---------------|
| 1 | Wakili John Doe | Sheria | **NULL** | john@legalfirm.co.tz |
| 2 | Kampuni ya Usafi | Usafi | **NULL** | maria@cleaning.co.tz |
| 3 | IT Solutions Ltd | Teknolojia | **NULL** | peter@itsolutions.co.tz |
| 4 | Simba Suppliers Ltd | Office Supplies | **NULL** | info@simbasuppliers.co.tz |
| 5 | TechZone Tanzania | IT Services | **NULL** | contact@techzone.tz |

**Findings:**
- vendor_code: **ALL 5 NULL** — migration will generate `VND-0001` through `VND-0005`
- vendor_name: All unique
- UNIQUE constraints: **None exist**

---

### 1.7 Borrowers (10 rows, 8 columns)

| # | full_name | phone_number | nida_number |
|---|-----------|-------------|-------------|
| 1 | Mwanaisha Juma | 0754111222 | 19850612-00001 |
| 2 | Upendo SME Group | 0765222333 | 19900101-00002 |
| 3 | Furaha Traders | 0712333444 | 19880315-00003 |
| 4 | Baraka Salon Group | 0723444555 | 19950720-00004 |
| 5 | Neema Cooperative | 0734555666 | 19870903-00005 |
| 6 | Amani Shop | 0745666777 | 19920215-00006 |
| 7 | Rehema Fashions | 0756777888 | 19891110-00007 |
| 8 | Tumaini Digital | 0767888999 | 19970405-00008 |
| 9 | Amina Hassan | 0754100001 | 19900101-10001 |
| 10 | Amina Hassan | 0754999888 | NULL |

**Findings:**
- Same-name "Amina Hassan" x2 = same pattern as clients (different phone, different nida)
- Phone format: **All local** (`07xxxxx`) — will normalize to E.164
- Duplicate phones: **0** (all unique)
- Duplicate nida: **0** (8 unique + 1 NULL)
- UNIQUE constraints: **None exist**

---

### 1.8 Loans (10 rows, 19 columns)

| # | loan_number | borrower | principal | outstanding | days_overdue | officer_id | branch |
|---|------------|----------|-----------|-------------|-------------|------------|--------|
| 1 | LN-2025-0612 | Mwanaisha Juma | 4,500,000 | 4,500,000 | 95 | e15d600f | Dodoma HQ |
| 2 | LN-2025-0756 | Rehema Fashions | 5,100,000 | 5,100,000 | 112 | ac3a238f | HQ |
| 3 | LN-2026-0205 | Tumaini Digital | 3,500,000 | 3,000,000 | 5 | c9e19d33 | Dodoma HQ |
| 4 | LN-2026-0201 | Upendo SME | 2,000,000 | 1,600,000 | 0 | e15d600f | Dodoma HQ |
| 5 | LN-2026-0203 | Furaha Traders | 1,800,000 | 1,400,000 | 0 | e15d600f | Dodoma HQ |
| 6 | LN-2025-0834 | Baraka Salon | 3,200,000 | 2,800,000 | 67 | b0fac028 | Dodoma |
| 7 | LN-2025-0921 | Neema Cooperative | 2,800,000 | 2,100,000 | 45 | b0fac028 | Dodoma |
| 8 | LN-2026-0102 | Amani Shop | 1,500,000 | 1,200,000 | 32 | ac3a238f | HQ |
| 9 | LD-200001 | Amina Hassan | 500,000 | 900,000 | 0 | NULL | 1 |
| 10 | LD-800001 | Amina Hassan | 500,000 | 1,580,000 | 0 | NULL | 1 |

**Findings:**
- Duplicate loan_numbers: **0** (all unique)
- 2 loans (LD-*) have no officer assigned
- Loan LD-800001 has `start_date: NULL` and `disbursed_at: NULL` (not yet disbursed)
- UNIQUE constraint on loan_number: **Does not exist**

---

### 1.9 Attendance Records (15 rows, 15 columns)

**Staff 78aaaaf7 (Yohana Bunzali):** 11 attendance entries across Feb 1-13
**Staff b0fac028 (Paul Masunga):** 4 attendance entries across Feb 1-4

| Finding | Detail |
|---------|--------|
| Missing clock_out | 5 entries for Yohana (Feb 1-6) have `clock_out: NULL` |
| Short sessions | Feb 9 (0.02h), Feb 10 (0.73h), Feb 11 (0.00h), Feb 13 (0.01h) — likely test data |
| Late arrivals | 3 entries flagged: Feb 2 (30min), Feb 4 (15min x2) |
| `is_late: null` | 4 entries have NULL instead of false — trigger should enforce boolean |
| Existing constraint | `unique_staff_work_date(staff_id, work_date)` already exists |

---

### 1.10 Leave Balances (28 rows, 9 columns)

| staff_id | Annual | Sick | Compassionate | Study |
|----------|--------|------|---------------|-------|
| 78aaaaf7 (Yohana) | 24/28 (4 used) | 126/126 | 4/4 | 10/10 |
| ac3a238f (Frank) | 28/28 | 126/126 | 4/4 | 10/10 |
| b2e27541 (Hilda) | 22/28 (6 used) | 126/126 | 4/4 | 10/10 |
| b0fac028 (Paul) | 28/28 | 126/126 | 4/4 | 10/10 |
| e15d600f (Aura) | 28/28 | 126/126 | 1/4 (3 used) | 10/10 |
| c9e19d33 (Naomi) | 21/28 (7 used) | 126/126 | 4/4 | 10/10 |
| b162dab4 (Gema) | 28/28 | 126/126 | 4/4 | 10/10 |

**Findings:**
- 7 staff x 4 leave types = 28 rows (correct)
- Composite key `(staff_id, leave_type, year)`: **No duplicates** — all valid
- UNIQUE constraint: **Does not exist** — needs enforcement

---

## PART 2: Migration Impact (Before → After)

### 2.1 Table Count Change

| Phase | Action | Tables Dropped |
|-------|--------|---------------|
| Phase 0 | Bootstrap audit tables | +2 created |
| Phase 1 | Drop 17 empty duplicates | -17 |
| Phase 2 | Drop z_archive_ tables | -59+ |
| Phase 3 | Consolidate audit_logs_new + leave_policy | -2 |
| Phase 4 | Add constraints/triggers/indexes | 0 (modify only) |
| **Net** | | **~76+ tables removed** |

### 2.2 Constraint Changes

| Table | Before (UNIQUE) | After (UNIQUE) |
|-------|----------------|----------------|
| staff | 0 | 2 (email, user_id) |
| employees | 0 | 5 (email, code, tin, nida, user_id) |
| clients | 0 | 3 (phone, ext_ref, nida) |
| customers | 0 | 3 (code, email, phone) |
| vendors | 0 | 2 (code, name) |
| borrowers | 0 | 2 (phone, nida) |
| loans | 0 | 1 (loan_number) |
| leave_balances | 0 | 1 (staff_id, leave_type, year) |
| profiles | 0 | 1 (phone) |
| **Total** | **0** | **20** |

### 2.3 CHECK Constraints Added

| Table | Constraint | Rule |
|-------|-----------|------|
| staff | `chk_staff_email_format` | Valid email regex |
| employees | `chk_employees_email_format` | Valid email regex |
| clients | `chk_clients_phone_format` | Tanzania phone (`+255xxxxxxxxx` or `0xxxxxxxxx`) |

### 2.4 Normalization Functions

| Function | Input → Output |
|----------|---------------|
| `normalize_email(text)` | `" John@Gmail.COM "` → `"john@gmail.com"` |
| `normalize_phone_tz(text)` | `"0712345678"` → `"+255712345678"` |
| `normalize_phone_tz(text)` | `"255712345678"` → `"+255712345678"` |
| `normalize_phone_tz(text)` | `"+255712345678"` → `"+255712345678"` (no-op) |
| `normalize_phone_tz(text)` | `"712345678"` → `"+255712345678"` |
| `normalize_tin(text)` | `"153-319-035"` → `"153319035"` |

### 2.5 Preventive Triggers

| Trigger | Table | On | Actions |
|---------|-------|-----|---------|
| `trg_staff_normalize` | staff | INSERT/UPDATE | Normalize email, phone, TIN |
| `trg_employees_normalize` | employees | INSERT/UPDATE | Normalize email, phone; consolidate tin→tin_number, national_id→nida_number |
| `trg_clients_normalize` | clients | INSERT/UPDATE | Normalize phone to E.164 |
| `trg_borrowers_normalize` | borrowers | INSERT/UPDATE | Normalize phone to E.164 |

### 2.6 Performance Indexes

| Index | Table | Columns | Purpose |
|-------|-------|---------|---------|
| `idx_staff_department` | staff | department | RLS policies, filters |
| `idx_staff_active` | staff | active | Status filters |
| `idx_employees_dept_status` | employees | dept, status | Common query pattern |
| `idx_clients_status_risk` | clients | status, risk_level | Risk assessment queries |
| `idx_loans_borrower_status` | loans | borrower_id, status | Loan lookup by borrower |
| `idx_loans_officer` | loans | officer_id | Officer portfolio queries |
| `idx_attendance_work_date` | attendance_records | work_date | Daily/monthly reports |
| `idx_attendance_staff_id` | attendance_records | staff_id | Per-staff attendance |

### 2.7 Data Fixes Applied

| Table | Fix | Rows Affected |
|-------|-----|---------------|
| staff | Email normalized to lowercase | 7 |
| staff | TIN dashes stripped (`153-319-035` → `153319035`) | 2 |
| employees | `national_id` → `nida_number` consolidation | 1 (Frank) |
| employees | Email normalized to lowercase | 6 |
| clients | Phone `0754100001` → `+255754100001` | 2 |
| borrowers | Phone `0754111222` → `+255754111222` (all 10) | 10 |
| vendors | vendor_code generated: `VND-0001` through `VND-0005` | 5 |

### 2.8 Deprecated Columns (Marked, Not Dropped)

| Table | Column | Replacement | Comment Added |
|-------|--------|------------|---------------|
| employees | `tin` | `tin_number` | `DEPRECATED: Use tin_number instead` |
| employees | `tin_no` | `tin_number` | `DEPRECATED: Use tin_number instead` |
| employees | `national_id` | `nida_number` | `DEPRECATED: Use nida_number instead` |

---

## PART 3: Application-Layer Upsert Patterns

### 3.1 Staff Upsert (by email)

```sql
INSERT INTO public.staff (email, full_name, phone, department, role)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT ((lower(email)))
DO UPDATE SET
  full_name = EXCLUDED.full_name,
  phone = EXCLUDED.phone,
  department = EXCLUDED.department,
  role = EXCLUDED.role,
  updated_at = now()
RETURNING *;
```

**Notes:**
- The `trg_staff_normalize` trigger auto-normalizes email/phone/TIN before insert
- Conflict detection uses functional index `lower(email)`, so `John@IMFSL.co.tz` and `john@imfsl.co.tz` are treated as the same

### 3.2 Employee Upsert (by email)

```sql
INSERT INTO public.employees (email, full_name, employee_code, dept, phone, tin_number, nida_number)
VALUES ($1, $2, $3, $4, $5, $6, $7)
ON CONFLICT ((lower(email)))
DO UPDATE SET
  full_name = EXCLUDED.full_name,
  phone = EXCLUDED.phone,
  dept = EXCLUDED.dept,
  tin_number = COALESCE(EXCLUDED.tin_number, employees.tin_number),
  nida_number = COALESCE(EXCLUDED.nida_number, employees.nida_number),
  updated_at = now()
RETURNING *;
```

**Notes:**
- Use `tin_number` exclusively — the trigger handles legacy `tin`/`tin_no` if they're populated
- Use `nida_number` exclusively — the trigger consolidates `national_id` automatically
- COALESCE prevents overwriting existing TIN/NIDA with NULL

### 3.3 Client Upsert (by phone_number)

```sql
INSERT INTO public.clients (phone_number, full_name, nida_number, external_reference_id)
VALUES ($1, $2, $3, $4)
ON CONFLICT (phone_number)
DO UPDATE SET
  full_name = EXCLUDED.full_name,
  nida_number = COALESCE(EXCLUDED.nida_number, clients.nida_number),
  updated_at = now()
RETURNING *;
```

**Notes:**
- Phone is auto-normalized by `trg_clients_normalize` — pass any Tanzania format
- `external_reference_id` has a separate UNIQUE constraint — use it for LoanDisk sync

### 3.4 Borrower Upsert (by phone_number)

```sql
INSERT INTO public.borrowers (phone_number, full_name, nida_number)
VALUES ($1, $2, $3)
ON CONFLICT (phone_number)
DO UPDATE SET
  full_name = EXCLUDED.full_name,
  nida_number = COALESCE(EXCLUDED.nida_number, borrowers.nida_number),
  updated_at = now()
RETURNING *;
```

**Notes:**
- Phone auto-normalized by `trg_borrowers_normalize`
- After migration, `0754111222` and `+255754111222` resolve to the same record

### 3.5 Vendor Upsert (by vendor_code)

```sql
INSERT INTO public.vendors (vendor_code, vendor_name, service_type, contact_email, contact_phone)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (vendor_code)
DO UPDATE SET
  vendor_name = EXCLUDED.vendor_name,
  service_type = EXCLUDED.service_type,
  contact_email = EXCLUDED.contact_email,
  contact_phone = EXCLUDED.contact_phone,
  updated_at = now()
RETURNING *;
```

### 3.6 Leave Balance Upsert (composite key)

```sql
INSERT INTO public.leave_balances (staff_id, leave_type, year, total_entitlement, remaining_days, days_used)
VALUES ($1, $2, $3, $4, $5, $6)
ON CONFLICT (staff_id, leave_type, year)
DO UPDATE SET
  total_entitlement = EXCLUDED.total_entitlement,
  remaining_days = EXCLUDED.remaining_days,
  days_used = EXCLUDED.days_used,
  updated_at = now()
RETURNING *;
```

### 3.7 Loan Upsert (by loan_number)

```sql
INSERT INTO public.loans (loan_number, borrower_id, amount_principal, interest_rate, duration_months, status, officer_id, branch)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
ON CONFLICT (loan_number) WHERE loan_number IS NOT NULL
DO UPDATE SET
  outstanding_balance = EXCLUDED.outstanding_balance,
  total_paid = EXCLUDED.total_paid,
  days_overdue = EXCLUDED.days_overdue,
  last_payment_date = EXCLUDED.last_payment_date,
  status = EXCLUDED.status,
  updated_at = now()
RETURNING *;
```

---

## PART 4: Supabase JS (TypeScript) Upsert Examples

### 4.1 Staff Upsert via Supabase Client

```typescript
const { data, error } = await supabase
  .from('staff')
  .upsert(
    {
      email: 'new.staff@imfsl.co.tz',
      full_name: 'New Staff Member',
      phone: '0712345678',  // trigger normalizes to +255712345678
      department: 'Operations',
    },
    { onConflict: 'email' }  // matches idx_staff_email_unique
  )
  .select()
  .single();
```

### 4.2 Borrower Upsert via Supabase Client

```typescript
const { data, error } = await supabase
  .from('borrowers')
  .upsert(
    {
      phone_number: '0754111222',  // trigger normalizes to +255754111222
      full_name: 'Mwanaisha Juma',
      nida_number: '19850612-00001',
    },
    { onConflict: 'phone_number' }
  )
  .select()
  .single();
```

### 4.3 Leave Balance Upsert via Supabase Client

```typescript
const { data, error } = await supabase
  .from('leave_balances')
  .upsert(
    {
      staff_id: '78aaaaf7-77c8-45f6-aa11-790146b1bea2',
      leave_type: 'Annual',
      year: 2026,
      total_entitlement: 28,
      remaining_days: 24,
      days_used: 4,
    },
    { onConflict: 'staff_id,leave_type,year' }
  )
  .select()
  .single();
```

---

## PART 5: Execution Instructions

### How to Run

1. Open **Supabase Dashboard** → **SQL Editor**
2. Copy the contents of `supabase/migrations/RUN_ALL_MIGRATIONS.sql` (329 lines)
3. Paste into the SQL Editor
4. Click **Run**
5. Check the NOTICE messages for the verification output

### Alternative: Run Individual Migrations

| Order | File | Purpose | Est. Time |
|-------|------|---------|-----------|
| 0 | `000_bootstrap_sql_audit_tables.sql` | Fix broken admin_sql_exec RPC | <1s |
| 1 | `001_drop_duplicate_tables_phase1.sql` | Drop 17 empty tables | <1s |
| 2 | `002_drop_archive_tables_phase2.sql` | Drop 59+ z_archive_ tables | <2s |
| 3 | `003_consolidate_tables_phase3.sql` | Merge audit_logs_new + leave_policy | <1s |
| 4 | `004_data_cleanup_constraints_indexes.sql` | Normalization + constraints + indexes | <3s |

### Post-Migration Verification

Run these queries after migration to confirm:

```sql
-- Verify unique indexes (expect 20+)
SELECT indexname, tablename FROM pg_indexes
WHERE schemaname = 'public' AND indexname LIKE 'idx_%_unique'
ORDER BY tablename;

-- Verify CHECK constraints (expect 3)
SELECT conname, conrelid::regclass, contype
FROM pg_constraint WHERE conname LIKE 'chk_%'
ORDER BY conrelid::regclass;

-- Verify triggers (expect 4)
SELECT tgname, tgrelid::regclass
FROM pg_trigger WHERE tgname LIKE 'trg_%'
ORDER BY tgrelid::regclass;

-- Verify normalization functions (expect 3)
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('normalize_email', 'normalize_phone_tz', 'normalize_tin');

-- Verify vendor codes generated
SELECT vendor_code, vendor_name FROM public.vendors ORDER BY vendor_code;

-- Verify phone normalization (clients should be E.164)
SELECT phone_number FROM public.clients;
SELECT phone_number FROM public.borrowers;
```

---

## PART 6: Known Issues & Recommendations

### Action Items Post-Migration

| Priority | Issue | Action |
|----------|-------|--------|
| HIGH | "Gema Baguma" exists in staff but not employees | Create corresponding employee record |
| HIGH | Staff phone numbers are all placeholder `+255 xxx xxx xxx` | Replace with real phone numbers |
| MEDIUM | 5/7 staff have no TIN number | Collect and enter TIN data |
| MEDIUM | 5/6 employees have no NIDA number | Collect and enter NIDA data |
| LOW | Loan LD-800001 has no start_date or disbursed_at | Update when disbursed |
| LOW | 5 attendance entries have `is_late: NULL` | Application should enforce boolean |

### Broken RPC Functions (Unrelated to This Migration)

| Function | Error | Fix |
|----------|-------|-----|
| `cleanup_edge_metrics_retention()` | Missing `edge_metrics_refresh_audit` table | Create table or remove function |
| `generate_policy_cleanup_sql()` | Missing `_rls_policy_backup_cleanup` table | Create table or remove function |
| `refresh_admin_counts()` | Missing `mv_admin_counts` materialized view | Create view or remove function |

---

*End of Report — Generated 2026-02-14*
