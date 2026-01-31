import '../database.dart';

class CollectionCasesTable extends SupabaseTable<CollectionCasesRow> {
  @override
  String get tableName => 'collection_cases';

  @override
  CollectionCasesRow createRow(Map<String, dynamic> data) =>
      CollectionCasesRow(data);
}

class CollectionCasesRow extends SupabaseDataRow {
  CollectionCasesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionCasesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  int get dpdDays => getField<int>('dpd_days')!;
  set dpdDays(int value) => setField<int>('dpd_days', value);

  String get dpdBucket => getField<String>('dpd_bucket')!;
  set dpdBucket(String value) => setField<String>('dpd_bucket', value);

  double get outstandingAmount => getField<double>('outstanding_amount')!;
  set outstandingAmount(double value) =>
      setField<double>('outstanding_amount', value);

  double get originalAmount => getField<double>('original_amount')!;
  set originalAmount(double value) =>
      setField<double>('original_amount', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get assignedTo => getField<String>('assigned_to');
  set assignedTo(String? value) => setField<String>('assigned_to', value);

  String? get segmentId => getField<String>('segment_id');
  set segmentId(String? value) => setField<String>('segment_id', value);

  String? get escalationLevel => getField<String>('escalation_level');
  set escalationLevel(String? value) =>
      setField<String>('escalation_level', value);

  String? get clientPhone => getField<String>('client_phone');
  set clientPhone(String? value) => setField<String>('client_phone', value);

  String? get clientName => getField<String>('client_name');
  set clientName(String? value) => setField<String>('client_name', value);

  int get contactAttempts => getField<int>('contact_attempts')!;
  set contactAttempts(int value) => setField<int>('contact_attempts', value);

  DateTime? get lastContactAt => getField<DateTime>('last_contact_at');
  set lastContactAt(DateTime? value) =>
      setField<DateTime>('last_contact_at', value);

  DateTime? get nextActionDate => getField<DateTime>('next_action_date');
  set nextActionDate(DateTime? value) =>
      setField<DateTime>('next_action_date', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);

  String? get resolvedBy => getField<String>('resolved_by');
  set resolvedBy(String? value) => setField<String>('resolved_by', value);

  String? get resolutionType => getField<String>('resolution_type');
  set resolutionType(String? value) =>
      setField<String>('resolution_type', value);

  double? get resolutionAmount => getField<double>('resolution_amount');
  set resolutionAmount(double? value) =>
      setField<double>('resolution_amount', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  int? get behaviorScore => getField<int>('behavior_score');
  set behaviorScore(int? value) => setField<int>('behavior_score', value);

  String? get behaviorBand => getField<String>('behavior_band');
  set behaviorBand(String? value) => setField<String>('behavior_band', value);

  String? get preferredChannel => getField<String>('preferred_channel');
  set preferredChannel(String? value) =>
      setField<String>('preferred_channel', value);

  String? get bestContactTime => getField<String>('best_contact_time');
  set bestContactTime(String? value) =>
      setField<String>('best_contact_time', value);

  bool? get lastPromiseKept => getField<bool>('last_promise_kept');
  set lastPromiseKept(bool? value) =>
      setField<bool>('last_promise_kept', value);

  double? get ptpSuccessRate => getField<double>('ptp_success_rate');
  set ptpSuccessRate(double? value) =>
      setField<double>('ptp_success_rate', value);

  int? get totalPtpCount => getField<int>('total_ptp_count');
  set totalPtpCount(int? value) => setField<int>('total_ptp_count', value);

  int? get keptPtpCount => getField<int>('kept_ptp_count');
  set keptPtpCount(int? value) => setField<int>('kept_ptp_count', value);

  String? get contactResponsiveness =>
      getField<String>('contact_responsiveness');
  set contactResponsiveness(String? value) =>
      setField<String>('contact_responsiveness', value);

  bool? get autoEscalateBlocked => getField<bool>('auto_escalate_blocked');
  set autoEscalateBlocked(bool? value) =>
      setField<bool>('auto_escalate_blocked', value);

  bool? get autoMessageBlocked => getField<bool>('auto_message_blocked');
  set autoMessageBlocked(bool? value) =>
      setField<bool>('auto_message_blocked', value);

  DateTime? get nextScheduledContact =>
      getField<DateTime>('next_scheduled_contact');
  set nextScheduledContact(DateTime? value) =>
      setField<DateTime>('next_scheduled_contact', value);

  int? get lastMessageResponseHours =>
      getField<int>('last_message_response_hours');
  set lastMessageResponseHours(int? value) =>
      setField<int>('last_message_response_hours', value);
}
