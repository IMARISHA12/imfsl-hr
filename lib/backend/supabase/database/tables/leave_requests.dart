import '../database.dart';

class LeaveRequestsTable extends SupabaseTable<LeaveRequestsRow> {
  @override
  String get tableName => 'leave_requests';

  @override
  LeaveRequestsRow createRow(Map<String, dynamic> data) =>
      LeaveRequestsRow(data);
}

class LeaveRequestsRow extends SupabaseDataRow {
  LeaveRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LeaveRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get leaveTypeId => getField<String>('leave_type_id')!;
  set leaveTypeId(String value) => setField<String>('leave_type_id', value);

  DateTime get startDate => getField<DateTime>('start_date')!;
  set startDate(DateTime value) => setField<DateTime>('start_date', value);

  DateTime get endDate => getField<DateTime>('end_date')!;
  set endDate(DateTime value) => setField<DateTime>('end_date', value);

  int get daysCount => getField<int>('days_count')!;
  set daysCount(int value) => setField<int>('days_count', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get managerComment => getField<String>('manager_comment');
  set managerComment(String? value) =>
      setField<String>('manager_comment', value);

  String? get attachmentUrl => getField<String>('attachment_url');
  set attachmentUrl(String? value) => setField<String>('attachment_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
