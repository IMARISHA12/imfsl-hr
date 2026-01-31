import '../database.dart';

class LegalCaseEventsTable extends SupabaseTable<LegalCaseEventsRow> {
  @override
  String get tableName => 'legal_case_events';

  @override
  LegalCaseEventsRow createRow(Map<String, dynamic> data) =>
      LegalCaseEventsRow(data);
}

class LegalCaseEventsRow extends SupabaseDataRow {
  LegalCaseEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalCaseEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  DateTime get eventDate => getField<DateTime>('event_date')!;
  set eventDate(DateTime value) => setField<DateTime>('event_date', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  List<String> get documentIds => getListField<String>('document_ids');
  set documentIds(List<String>? value) =>
      setListField<String>('document_ids', value);

  String? get outcome => getField<String>('outcome');
  set outcome(String? value) => setField<String>('outcome', value);

  String? get recordedBy => getField<String>('recorded_by');
  set recordedBy(String? value) => setField<String>('recorded_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
