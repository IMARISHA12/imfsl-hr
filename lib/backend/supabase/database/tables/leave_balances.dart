import '../database.dart';

class LeaveBalancesTable extends SupabaseTable<LeaveBalancesRow> {
  @override
  String get tableName => 'leave_balances';

  @override
  LeaveBalancesRow createRow(Map<String, dynamic> data) =>
      LeaveBalancesRow(data);
}

class LeaveBalancesRow extends SupabaseDataRow {
  LeaveBalancesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LeaveBalancesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  String get leaveType => getField<String>('leave_type')!;
  set leaveType(String value) => setField<String>('leave_type', value);

  int? get remainingDays => getField<int>('remaining_days');
  set remainingDays(int? value) => setField<int>('remaining_days', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
