import '../database.dart';

class LegalCaseTimelineTable extends SupabaseTable<LegalCaseTimelineRow> {
  @override
  String get tableName => 'legal_case_timeline';

  @override
  LegalCaseTimelineRow createRow(Map<String, dynamic> data) =>
      LegalCaseTimelineRow(data);
}

class LegalCaseTimelineRow extends SupabaseDataRow {
  LegalCaseTimelineRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalCaseTimelineTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  DateTime get eventDate => getField<DateTime>('event_date')!;
  set eventDate(DateTime value) => setField<DateTime>('event_date', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get outcome => getField<String>('outcome');
  set outcome(String? value) => setField<String>('outcome', value);

  dynamic get documents => getField<dynamic>('documents');
  set documents(dynamic value) => setField<dynamic>('documents', value);

  String? get recordedBy => getField<String>('recorded_by');
  set recordedBy(String? value) => setField<String>('recorded_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
