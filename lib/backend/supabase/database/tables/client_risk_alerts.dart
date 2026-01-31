import '../database.dart';

class ClientRiskAlertsTable extends SupabaseTable<ClientRiskAlertsRow> {
  @override
  String get tableName => 'client_risk_alerts';

  @override
  ClientRiskAlertsRow createRow(Map<String, dynamic> data) =>
      ClientRiskAlertsRow(data);
}

class ClientRiskAlertsRow extends SupabaseDataRow {
  ClientRiskAlertsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClientRiskAlertsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  String get alertType => getField<String>('alert_type')!;
  set alertType(String value) => setField<String>('alert_type', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get relatedLoanId => getField<String>('related_loan_id');
  set relatedLoanId(String? value) =>
      setField<String>('related_loan_id', value);

  bool? get isAcknowledged => getField<bool>('is_acknowledged');
  set isAcknowledged(bool? value) => setField<bool>('is_acknowledged', value);

  String? get acknowledgedBy => getField<String>('acknowledged_by');
  set acknowledgedBy(String? value) =>
      setField<String>('acknowledged_by', value);

  DateTime? get acknowledgedAt => getField<DateTime>('acknowledged_at');
  set acknowledgedAt(DateTime? value) =>
      setField<DateTime>('acknowledged_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);
}
