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

  int? get totalDays => getField<int>('total_days');
  set totalDays(int? value) => setField<int>('total_days', value);

  String? get attachmentUrl => getField<String>('attachment_url');
  set attachmentUrl(String? value) => setField<String>('attachment_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get reviewerComments => getField<String>('reviewer_comments');
  set reviewerComments(String? value) =>
      setField<String>('reviewer_comments', value);

  DateTime? get photoCapturedAt => getField<DateTime>('photo_captured_at');
  set photoCapturedAt(DateTime? value) =>
      setField<DateTime>('photo_captured_at', value);

  double? get captureLatitude => getField<double>('capture_latitude');
  set captureLatitude(double? value) =>
      setField<double>('capture_latitude', value);

  double? get captureLongitude => getField<double>('capture_longitude');
  set captureLongitude(double? value) =>
      setField<double>('capture_longitude', value);

  bool? get documentVerified => getField<bool>('document_verified');
  set documentVerified(bool? value) =>
      setField<bool>('document_verified', value);

  String? get verificationNotes => getField<String>('verification_notes');
  set verificationNotes(String? value) =>
      setField<String>('verification_notes', value);

  bool? get isFlagged => getField<bool>('is_flagged');
  set isFlagged(bool? value) => setField<bool>('is_flagged', value);

  String? get flagReason => getField<String>('flag_reason');
  set flagReason(String? value) => setField<String>('flag_reason', value);
}
