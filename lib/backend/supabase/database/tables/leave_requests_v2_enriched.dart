import '../database.dart';

class LeaveRequestsV2EnrichedTable
    extends SupabaseTable<LeaveRequestsV2EnrichedRow> {
  @override
  String get tableName => 'leave_requests_v2_enriched';

  @override
  LeaveRequestsV2EnrichedRow createRow(Map<String, dynamic> data) =>
      LeaveRequestsV2EnrichedRow(data);
}

class LeaveRequestsV2EnrichedRow extends SupabaseDataRow {
  LeaveRequestsV2EnrichedRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LeaveRequestsV2EnrichedTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  String? get staffName => getField<String>('staff_name');
  set staffName(String? value) => setField<String>('staff_name', value);

  String? get staffEmail => getField<String>('staff_email');
  set staffEmail(String? value) => setField<String>('staff_email', value);

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

  bool? get isActiveNow => getField<bool>('is_active_now');
  set isActiveNow(bool? value) => setField<bool>('is_active_now', value);
}
