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

  String? get leaveType => getField<String>('leave_type');
  set leaveType(String? value) => setField<String>('leave_type', value);

  DateTime? get startDate => getField<DateTime>('start_date');
  set startDate(DateTime? value) => setField<DateTime>('start_date', value);

  DateTime? get endDate => getField<DateTime>('end_date');
  set endDate(DateTime? value) => setField<DateTime>('end_date', value);

  int? get totalDays => getField<int>('total_days');
  set totalDays(int? value) => setField<int>('total_days', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  String? get attachmentUrl => getField<String>('attachment_url');
  set attachmentUrl(String? value) => setField<String>('attachment_url', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get reviewerComments => getField<String>('reviewer_comments');
  set reviewerComments(String? value) =>
      setField<String>('reviewer_comments', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get staffName => getField<String>('staff_name');
  set staffName(String? value) => setField<String>('staff_name', value);

  String? get staffEmail => getField<String>('staff_email');
  set staffEmail(String? value) => setField<String>('staff_email', value);

  String? get leaveTypeDisplay => getField<String>('leave_type_display');
  set leaveTypeDisplay(String? value) =>
      setField<String>('leave_type_display', value);
}
