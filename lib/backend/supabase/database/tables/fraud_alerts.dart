import '../database.dart';

class FraudAlertsTable extends SupabaseTable<FraudAlertsRow> {
  @override
  String get tableName => 'fraud_alerts';

  @override
  FraudAlertsRow createRow(Map<String, dynamic> data) => FraudAlertsRow(data);
}

class FraudAlertsRow extends SupabaseDataRow {
  FraudAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FraudAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get alertType => getField<String>('alert_type')!;
  set alertType(String value) => setField<String>('alert_type', value);

  String? get alertCode => getField<String>('alert_code');
  set alertCode(String? value) => setField<String>('alert_code', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  String? get clientId => getField<String>('client_id');
  set clientId(String? value) => setField<String>('client_id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get transactionId => getField<String>('transaction_id');
  set transactionId(String? value) => setField<String>('transaction_id', value);

  int? get fraudScore => getField<int>('fraud_score');
  set fraudScore(int? value) => setField<int>('fraud_score', value);

  String? get detectionMethod => getField<String>('detection_method');
  set detectionMethod(String? value) =>
      setField<String>('detection_method', value);

  String? get detectionRule => getField<String>('detection_rule');
  set detectionRule(String? value) => setField<String>('detection_rule', value);

  dynamic get evidence => getField<dynamic>('evidence')!;
  set evidence(dynamic value) => setField<dynamic>('evidence', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get assignedTo => getField<String>('assigned_to');
  set assignedTo(String? value) => setField<String>('assigned_to', value);

  DateTime? get assignedAt => getField<DateTime>('assigned_at');
  set assignedAt(DateTime? value) => setField<DateTime>('assigned_at', value);

  String? get investigationNotes => getField<String>('investigation_notes');
  set investigationNotes(String? value) =>
      setField<String>('investigation_notes', value);

  DateTime? get investigationStartedAt =>
      getField<DateTime>('investigation_started_at');
  set investigationStartedAt(DateTime? value) =>
      setField<DateTime>('investigation_started_at', value);

  String? get resolution => getField<String>('resolution');
  set resolution(String? value) => setField<String>('resolution', value);

  String? get resolutionNotes => getField<String>('resolution_notes');
  set resolutionNotes(String? value) =>
      setField<String>('resolution_notes', value);

  String? get resolvedBy => getField<String>('resolved_by');
  set resolvedBy(String? value) => setField<String>('resolved_by', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);

  String? get actionTaken => getField<String>('action_taken');
  set actionTaken(String? value) => setField<String>('action_taken', value);

  String? get disciplinaryRecordId =>
      getField<String>('disciplinary_record_id');
  set disciplinaryRecordId(String? value) =>
      setField<String>('disciplinary_record_id', value);

  DateTime get detectedAt => getField<DateTime>('detected_at')!;
  set detectedAt(DateTime value) => setField<DateTime>('detected_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
