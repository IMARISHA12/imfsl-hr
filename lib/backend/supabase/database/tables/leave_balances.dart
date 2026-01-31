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

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get leaveTypeId => getField<String>('leave_type_id')!;
  set leaveTypeId(String value) => setField<String>('leave_type_id', value);

  int get year => getField<int>('year')!;
  set year(int value) => setField<int>('year', value);

  int? get remainingDays => getField<int>('remaining_days');
  set remainingDays(int? value) => setField<int>('remaining_days', value);

  int? get usedDays => getField<int>('used_days');
  set usedDays(int? value) => setField<int>('used_days', value);

  int? get annualEntitlement => getField<int>('annual_entitlement');
  set annualEntitlement(int? value) =>
      setField<int>('annual_entitlement', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
