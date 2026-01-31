import '../database.dart';

class ClaimsNewTable extends SupabaseTable<ClaimsNewRow> {
  @override
  String get tableName => 'claims_new';

  @override
  ClaimsNewRow createRow(Map<String, dynamic> data) => ClaimsNewRow(data);
}

class ClaimsNewRow extends SupabaseDataRow {
  ClaimsNewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClaimsNewTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get policyId => getField<String>('policy_id')!;
  set policyId(String value) => setField<String>('policy_id', value);

  DateTime get incidentDate => getField<DateTime>('incident_date')!;
  set incidentDate(DateTime value) =>
      setField<DateTime>('incident_date', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  dynamic get evidenceUrls => getField<dynamic>('evidence_urls');
  set evidenceUrls(dynamic value) => setField<dynamic>('evidence_urls', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double? get approvedAmount => getField<double>('approved_amount');
  set approvedAmount(double? value) =>
      setField<double>('approved_amount', value);

  String? get assessorNotes => getField<String>('assessor_notes');
  set assessorNotes(String? value) => setField<String>('assessor_notes', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
