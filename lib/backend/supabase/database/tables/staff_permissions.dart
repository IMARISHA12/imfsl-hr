import '../database.dart';

class StaffPermissionsTable extends SupabaseTable<StaffPermissionsRow> {
  @override
  String get tableName => 'staff_permissions';

  @override
  StaffPermissionsRow createRow(Map<String, dynamic> data) =>
      StaffPermissionsRow(data);
}

class StaffPermissionsRow extends SupabaseDataRow {
  StaffPermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffPermissionsTable();

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  bool get canApproveLoans => getField<bool>('can_approve_loans')!;
  set canApproveLoans(bool value) => setField<bool>('can_approve_loans', value);

  bool get canManageStaff => getField<bool>('can_manage_staff')!;
  set canManageStaff(bool value) => setField<bool>('can_manage_staff', value);

  bool get canViewPii => getField<bool>('can_view_pii')!;
  set canViewPii(bool value) => setField<bool>('can_view_pii', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
