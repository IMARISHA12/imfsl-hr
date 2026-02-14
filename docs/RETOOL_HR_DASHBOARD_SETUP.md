# Retool HR Dashboard — Setup Guide

## Architecture

```
Retool HR Module
  ├── Supabase Resource (existing)
  │     ├── Views:  v_department_summary, v_employee_directory,
  │     │           v_leave_dashboard, v_attendance_dashboard,
  │     │           v_payroll_dashboard, v_performance_dashboard
  │     ├── RPC:    rpc_generate_payslips, rpc_approve_payroll,
  │     │           rpc_submit_leave_request, rpc_clock_in, rpc_clock_out, ...
  │     └── Tables: employees, payroll_runs, leave_requests, attendance_records
  │
  └── Edge Functions (HR)
        ├── hr-payroll-processor:   Payroll lifecycle operations
        ├── hr-leave-workflow:      Leave approval workflows
        ├── hr-attendance:          Clock-in/out & tracking
        └── hr-performance-review:  Review cycles & scoring
```

## Prerequisites

- Supabase resource already configured in Retool
- Migrations 007–009 applied to database
- Seed 003 (HR master data) loaded
- HR edge functions deployed

---

## Page 1: Employee Directory

### Query: `getEmployees`

```sql
-- Supabase SQL query
SELECT * FROM v_employee_directory
ORDER BY department, full_name;
```

### Query: `getDepartmentSummary`

```sql
SELECT * FROM v_department_summary;
```

### Layout

- **Stats row**: Total headcount, active count, avg tenure, departments
- **Table**: Employee directory with search/filter by department, status
- **Sidebar**: Employee detail panel (click row to expand)

### Button: Add Employee

```javascript
// Supabase insert
const { data, error } = await supabase
  .from('employees')
  .insert({
    full_name: fullNameInput.value,
    employee_code: employeeCodeInput.value,
    dept: departmentSelect.value,
    email: emailInput.value,
    phone_number: phoneInput.value,
    hire_date: hireDatePicker.value,
    employment_status: 'active'
  });
```

---

## Page 2: Payroll Dashboard

### Query: `getPayrollRuns`

```sql
SELECT * FROM v_payroll_dashboard
ORDER BY run_period_year DESC, run_period_month DESC;
```

### Query: `getPayslips`

```sql
SELECT * FROM payslips
WHERE payroll_run_id = {{ payrollRunsTable.selectedRow.payroll_run_id }}
ORDER BY department, employee_name;
```

### Button: Create Payroll Run

```javascript
// Edge Function call
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-payroll-processor',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'create_run',
      month: monthSelect.value,
      year: yearSelect.value
    })
  }
);
return response.json();
```

### Button: Generate Payslips

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-payroll-processor',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'generate',
      payroll_run_id: payrollRunsTable.selectedRow.payroll_run_id
    })
  }
);
return response.json();
```

### Button: Approve Payroll

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-payroll-processor',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'approve',
      payroll_run_id: payrollRunsTable.selectedRow.payroll_run_id,
      approved_by: currentUser.email
    })
  }
);
return response.json();
```

### Button: Export Bank File

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-payroll-processor',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'bank_export',
      payroll_run_id: payrollRunsTable.selectedRow.payroll_run_id
    })
  }
);
const data = await response.json();
// data.bank_file_rows contains rows for CSV export
utils.downloadFile({ data: data.csv_content, fileName: `payroll_${data.month}.csv` });
```

### Payroll Summary Card

```sql
-- RPC call
SELECT * FROM rpc_hr_dashboard_kpis();
-- Returns: total_employees, monthly_payroll_cost, avg_salary, departments, etc.
```

---

## Page 3: Leave Management

### Query: `getPendingLeaves`

```sql
SELECT lr.*, lt.leave_type, e.full_name, e.dept
FROM leave_requests lr
JOIN leave_types lt ON lt.id = lr.leave_type_id
JOIN employees e ON e.user_id = lr.user_id
WHERE lr.status = 'pending'
ORDER BY lr.created_at DESC;
```

### Query: `getLeaveBalances`

```sql
SELECT lb.*, lt.leave_type, e.full_name
FROM leave_balances lb
JOIN leave_types lt ON lt.id = lb.leave_type_id
JOIN employees e ON e.user_id = lb.user_id
WHERE lb.year = {{ yearSelect.value || new Date().getFullYear() }}
ORDER BY e.full_name, lt.leave_type;
```

### Query: `getTeamCalendar`

```javascript
// Edge Function call
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-leave-workflow',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'team_calendar',
      start_date: startDatePicker.value,
      end_date: endDatePicker.value,
      department: departmentFilter.value || undefined
    })
  }
);
return response.json();
```

### Button: Approve Leave

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-leave-workflow',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'approve',
      request_id: pendingLeavesTable.selectedRow.id,
      manager_comment: approvalCommentInput.value,
      processed_by: currentUser.email
    })
  }
);
return response.json();
```

### Button: Reject Leave

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-leave-workflow',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'reject',
      request_id: pendingLeavesTable.selectedRow.id,
      manager_comment: rejectionReasonInput.value,
      processed_by: currentUser.email
    })
  }
);
return response.json();
```

### Button: Initialize Year Balances

```javascript
// Run once at start of year to allocate leave for all staff
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-leave-workflow',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'init_year',
      year: new Date().getFullYear()
    })
  }
);
return response.json();
```

---

## Page 4: Attendance Tracker

### Query: `getTodayAttendance`

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-attendance',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'today',
      department: departmentFilter.value || undefined
    })
  }
);
return response.json();
```

### Query: `getAttendanceSummary`

```sql
SELECT * FROM v_attendance_dashboard
WHERE work_date >= {{ startDate.value }}
  AND work_date <= {{ endDate.value }}
ORDER BY work_date DESC, staff_name;
```

### Layout

- **Stats cards**: Present today, absent, late, on-leave
- **Real-time table**: Today's clock-in/out status (auto-refresh every 60s)
- **Monthly chart**: Attendance rate by department (bar chart)
- **Calendar heat map**: Days × staff showing present/absent/late

### Button: Rate Attendance

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-attendance',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'rate',
      record_id: attendanceTable.selectedRow.id,
      rating: ratingSlider.value,
      manager_notes: managerNotesInput.value,
      rated_by: currentUser.email
    })
  }
);
return response.json();
```

---

## Page 5: Performance Reviews

### Query: `getReviewCycles`

```sql
SELECT * FROM performance_review_cycles
ORDER BY period_start DESC;
```

### Query: `getCycleSummary`

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-performance-review',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'cycle_summary',
      cycle_id: reviewCyclesTable.selectedRow.id,
      department: departmentFilter.value || undefined
    })
  }
);
return response.json();
```

### Query: `getPerformanceDashboard`

```sql
SELECT * FROM v_performance_dashboard
WHERE cycle_name = {{ reviewCyclesTable.selectedRow.cycle_name }}
ORDER BY overall_score DESC NULLS LAST;
```

### Layout

- **Cycle selector**: Dropdown of review cycles
- **Progress bar**: Pending → Self Review → Manager Review → Completed
- **Grade distribution**: Pie chart (A/B/C/D/F)
- **Rankings table**: Employee scores sortable by dimension
- **Department comparison**: Avg score by department (bar chart)

### Button: Create Review Cycle

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-performance-review',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'create_cycle',
      cycle_name: cycleNameInput.value,
      cycle_type: cycleTypeSelect.value,
      period_start: periodStartPicker.value,
      period_end: periodEndPicker.value,
      review_deadline: deadlinePicker.value,
      created_by: currentUser.email
    })
  }
);
return response.json();
```

### Button: Assign Reviews to All Staff

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-performance-review',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'assign_reviews',
      cycle_id: reviewCyclesTable.selectedRow.id
    })
  }
);
return response.json();
```

### Button: Calculate KPIs (Loan Officers)

```javascript
const response = await fetch(
  'https://lzyixazjquouicfsfzzu.supabase.co/functions/v1/hr-performance-review',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    },
    body: JSON.stringify({
      operation: 'calculate_kpis',
      cycle_id: reviewCyclesTable.selectedRow.id
    })
  }
);
return response.json();
```

---

## Page 6: HR Overview Dashboard

### Query: `getHRKPIs`

```sql
SELECT * FROM rpc_hr_dashboard_kpis();
```

### Query: `getNotifications`

```sql
SELECT * FROM hr_notifications
WHERE is_read = false
ORDER BY created_at DESC
LIMIT 10;
```

### Query: `getContractExpiries`

```sql
SELECT * FROM fn_contract_expiry_check(30);
```

### Layout

- **KPI cards**: Headcount, payroll cost, leave utilization, avg performance score
- **Pending actions**: Leave requests pending, unsigned contracts, overdue reviews
- **Notifications**: Recent unread HR events
- **Contract alerts**: Expiring in 30 days
- **Quick links**: Jump to Payroll, Leave, Attendance, Performance pages

---

## RPC Function Reference

| Function | Purpose | Parameters |
|---|---|---|
| `rpc_generate_payslips` | Generate all payslips for a run | `p_payroll_run_id, p_month, p_year` |
| `rpc_approve_payroll` | Approve a payroll run | `p_payroll_run_id, p_approved_by` |
| `rpc_payroll_bank_export` | Generate bank payment file | `p_payroll_run_id` |
| `rpc_submit_leave_request` | Submit a leave request | `p_user_id, p_leave_type_id, p_start_date, p_end_date, p_reason, p_attachment_url` |
| `rpc_process_leave_request` | Approve/reject leave | `p_request_id, p_action, p_manager_comment, p_processed_by` |
| `rpc_cancel_leave_request` | Cancel a leave request | `p_request_id, p_cancelled_by` |
| `rpc_initialize_leave_balances` | Init year leave allocations | `p_year` |
| `rpc_clock_in` | Record clock-in | `p_staff_id, p_latitude, p_longitude` |
| `rpc_clock_out` | Record clock-out | `p_staff_id, p_daily_report` |
| `rpc_rate_attendance` | Rate staff attendance | `p_record_id, p_rating, p_manager_notes, p_rated_by` |
| `rpc_attendance_summary` | Monthly summary | `p_month, p_year` |
| `rpc_submit_self_review` | Self-assessment scores | `p_review_id, p_quality, ...` |
| `rpc_submit_manager_review` | Manager assessment | `p_review_id, p_quality, ...` |
| `rpc_calculate_kpi_scores` | Auto-calc loan officer KPIs | `p_cycle_id` |
| `rpc_hr_dashboard_kpis` | Overview statistics | *(none)* |
| `rpc_unread_notification_count` | Unread badge count | *(none — uses auth.uid())* |
| `rpc_get_notifications` | Paginated notifications | `p_limit, p_offset, p_unread_only` |
| `rpc_mark_notifications_read` | Mark as read | `p_notification_ids` |

---

## View Reference

| View | Description | Key Columns |
|---|---|---|
| `v_department_summary` | Department-level aggregates | department, headcount, avg_salary, avg_tenure |
| `v_employee_directory` | Full employee listing | name, code, dept, status, hire_date, salary |
| `v_leave_dashboard` | Leave request details with types | employee, type, dates, status, days |
| `v_attendance_dashboard` | Attendance with employee info | staff, date, clock_in/out, hours, rating |
| `v_payroll_dashboard` | Payroll run summaries | month, status, total_cost, employee_count |
| `v_performance_dashboard` | Review scores by employee | name, cycle, scores, grade, rank |

---

## Scheduled Task Monitoring

Use the `scheduled_task_runs` table to monitor automated jobs:

```sql
SELECT task_name, status, started_at, completed_at,
       result->>'loans_updated' AS loans_updated,
       result->>'balances_updated' AS balances_updated,
       error_message
FROM scheduled_task_runs
ORDER BY started_at DESC
LIMIT 20;
```

Run a task manually:

```sql
SELECT fn_run_scheduled_task('daily_arrears_update');
SELECT fn_run_scheduled_task('monthly_leave_accrual');
SELECT fn_run_scheduled_task('attendance_autoclose');
SELECT fn_run_scheduled_task('contract_expiry_check');
SELECT fn_run_scheduled_task('loan_maturity_check');
```
