import '../database.dart';

class GovernmentLoanEventsTable extends SupabaseTable<GovernmentLoanEventsRow> {
  @override
  String get tableName => 'government_loan_events';

  @override
  GovernmentLoanEventsRow createRow(Map<String, dynamic> data) =>
      GovernmentLoanEventsRow(data);
}

class GovernmentLoanEventsRow extends SupabaseDataRow {
  GovernmentLoanEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GovernmentLoanEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanApplicationId => getField<String>('loan_application_id')!;
  set loanApplicationId(String value) =>
      setField<String>('loan_application_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String? get eventDescription => getField<String>('event_description');
  set eventDescription(String? value) =>
      setField<String>('event_description', value);

  String? get previousStatus => getField<String>('previous_status');
  set previousStatus(String? value) =>
      setField<String>('previous_status', value);

  String? get newStatus => getField<String>('new_status');
  set newStatus(String? value) => setField<String>('new_status', value);

  String? get performedBy => getField<String>('performed_by');
  set performedBy(String? value) => setField<String>('performed_by', value);

  DateTime? get performedAt => getField<DateTime>('performed_at');
  set performedAt(DateTime? value) => setField<DateTime>('performed_at', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);
}
