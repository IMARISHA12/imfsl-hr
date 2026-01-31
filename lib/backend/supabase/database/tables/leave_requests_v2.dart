import '../database.dart';

class LeaveRequestsV2Table extends SupabaseTable<LeaveRequestsV2Row> {
  @override
  String get tableName => 'leave_requests_v2';

  @override
  LeaveRequestsV2Row createRow(Map<String, dynamic> data) =>
      LeaveRequestsV2Row(data);
}

class LeaveRequestsV2Row extends SupabaseDataRow {
  LeaveRequestsV2Row(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LeaveRequestsV2Table();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  String? get leaveType => getField<String>('leave_type');
  set leaveType(String? value) => setField<String>('leave_type', value);

  DateTime? get startDate => getField<DateTime>('start_date');
  set startDate(DateTime? value) => setField<DateTime>('start_date', value);

  DateTime? get endDate => getField<DateTime>('end_date');
  set endDate(DateTime? value) => setField<DateTime>('end_date', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);
}
