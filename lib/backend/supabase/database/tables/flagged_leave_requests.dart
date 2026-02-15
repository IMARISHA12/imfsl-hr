import '../database.dart';

class FlaggedLeaveRequestsTable extends SupabaseTable<FlaggedLeaveRequestsRow> {
  @override
  String get tableName => 'flagged_leave_requests';

  @override
  FlaggedLeaveRequestsRow createRow(Map<String, dynamic> data) =>
      FlaggedLeaveRequestsRow(data);
}

class FlaggedLeaveRequestsRow extends SupabaseDataRow {
  FlaggedLeaveRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FlaggedLeaveRequestsTable();

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

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get attachmentUrl => getField<String>('attachment_url');
  set attachmentUrl(String? value) => setField<String>('attachment_url', value);

  DateTime? get photoCapturedAt => getField<DateTime>('photo_captured_at');
  set photoCapturedAt(DateTime? value) =>
      setField<DateTime>('photo_captured_at', value);

  double? get captureLatitude => getField<double>('capture_latitude');
  set captureLatitude(double? value) =>
      setField<double>('capture_latitude', value);

  double? get captureLongitude => getField<double>('capture_longitude');
  set captureLongitude(double? value) =>
      setField<double>('capture_longitude', value);

  bool? get isFlagged => getField<bool>('is_flagged');
  set isFlagged(bool? value) => setField<bool>('is_flagged', value);

  String? get flagReason => getField<String>('flag_reason');
  set flagReason(String? value) => setField<String>('flag_reason', value);

  bool? get documentVerified => getField<bool>('document_verified');
  set documentVerified(bool? value) =>
      setField<bool>('document_verified', value);

  String? get verificationNotes => getField<String>('verification_notes');
  set verificationNotes(String? value) =>
      setField<String>('verification_notes', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  int? get minutesBetweenCaptureAndSubmit =>
      getField<int>('minutes_between_capture_and_submit');
  set minutesBetweenCaptureAndSubmit(int? value) =>
      setField<int>('minutes_between_capture_and_submit', value);
}
