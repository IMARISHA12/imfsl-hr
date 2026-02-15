import '../database.dart';

class LeaveBalanceTable extends SupabaseTable<LeaveBalanceRow> {
  @override
  String get tableName => 'leave_balance';

  @override
  LeaveBalanceRow createRow(Map<String, dynamic> data) => LeaveBalanceRow(data);
}

class LeaveBalanceRow extends SupabaseDataRow {
  LeaveBalanceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LeaveBalanceTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  int? get annualLeave => getField<int>('annual_leave');
  set annualLeave(int? value) => setField<int>('annual_leave', value);

  int? get sickLeave => getField<int>('sick_leave');
  set sickLeave(int? value) => setField<int>('sick_leave', value);

  int? get maternityLeave => getField<int>('maternity_leave');
  set maternityLeave(int? value) => setField<int>('maternity_leave', value);

  int? get paternityLeave => getField<int>('paternity_leave');
  set paternityLeave(int? value) => setField<int>('paternity_leave', value);

  int? get emergencyLeave => getField<int>('emergency_leave');
  set emergencyLeave(int? value) => setField<int>('emergency_leave', value);

  int? get annualLeaveUsed => getField<int>('annual_leave_used');
  set annualLeaveUsed(int? value) => setField<int>('annual_leave_used', value);

  int? get sickLeaveUsed => getField<int>('sick_leave_used');
  set sickLeaveUsed(int? value) => setField<int>('sick_leave_used', value);

  int? get emergencyLeaveUsed => getField<int>('emergency_leave_used');
  set emergencyLeaveUsed(int? value) =>
      setField<int>('emergency_leave_used', value);

  int? get annualLeaveRemaining => getField<int>('annual_leave_remaining');
  set annualLeaveRemaining(int? value) =>
      setField<int>('annual_leave_remaining', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
