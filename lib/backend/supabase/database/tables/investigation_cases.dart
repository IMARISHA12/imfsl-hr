import '../database.dart';

class InvestigationCasesTable extends SupabaseTable<InvestigationCasesRow> {
  @override
  String get tableName => 'investigation_cases';

  @override
  InvestigationCasesRow createRow(Map<String, dynamic> data) =>
      InvestigationCasesRow(data);
}

class InvestigationCasesRow extends SupabaseDataRow {
  InvestigationCasesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => InvestigationCasesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseType => getField<String>('case_type')!;
  set caseType(String value) => setField<String>('case_type', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get priority => getField<String>('priority')!;
  set priority(String value) => setField<String>('priority', value);

  String? get assignedTo => getField<String>('assigned_to');
  set assignedTo(String? value) => setField<String>('assigned_to', value);

  dynamic get evidence => getField<dynamic>('evidence');
  set evidence(dynamic value) => setField<dynamic>('evidence', value);

  dynamic get findings => getField<dynamic>('findings');
  set findings(dynamic value) => setField<dynamic>('findings', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  DateTime? get closedAt => getField<DateTime>('closed_at');
  set closedAt(DateTime? value) => setField<DateTime>('closed_at', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);
}
