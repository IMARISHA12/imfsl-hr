import '../database.dart';

class CashVarianceInvestigationsTable
    extends SupabaseTable<CashVarianceInvestigationsRow> {
  @override
  String get tableName => 'cash_variance_investigations';

  @override
  CashVarianceInvestigationsRow createRow(Map<String, dynamic> data) =>
      CashVarianceInvestigationsRow(data);
}

class CashVarianceInvestigationsRow extends SupabaseDataRow {
  CashVarianceInvestigationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CashVarianceInvestigationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get cashCountId => getField<String>('cash_count_id')!;
  set cashCountId(String value) => setField<String>('cash_count_id', value);

  double get varianceAmount => getField<double>('variance_amount')!;
  set varianceAmount(double value) =>
      setField<double>('variance_amount', value);

  String get varianceType => getField<String>('variance_type')!;
  set varianceType(String value) => setField<String>('variance_type', value);

  String get investigationStatus => getField<String>('investigation_status')!;
  set investigationStatus(String value) =>
      setField<String>('investigation_status', value);

  String? get rootCause => getField<String>('root_cause');
  set rootCause(String? value) => setField<String>('root_cause', value);

  String? get correctiveAction => getField<String>('corrective_action');
  set correctiveAction(String? value) =>
      setField<String>('corrective_action', value);

  String? get resolutionType => getField<String>('resolution_type');
  set resolutionType(String? value) =>
      setField<String>('resolution_type', value);

  double? get resolutionAmount => getField<double>('resolution_amount');
  set resolutionAmount(double? value) =>
      setField<double>('resolution_amount', value);

  String? get resolutionNotes => getField<String>('resolution_notes');
  set resolutionNotes(String? value) =>
      setField<String>('resolution_notes', value);

  DateTime? get resolutionDate => getField<DateTime>('resolution_date');
  set resolutionDate(DateTime? value) =>
      setField<DateTime>('resolution_date', value);

  String? get investigatedBy => getField<String>('investigated_by');
  set investigatedBy(String? value) =>
      setField<String>('investigated_by', value);

  String? get resolvedBy => getField<String>('resolved_by');
  set resolvedBy(String? value) => setField<String>('resolved_by', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  List<String> get evidenceUrls => getListField<String>('evidence_urls');
  set evidenceUrls(List<String>? value) =>
      setListField<String>('evidence_urls', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
