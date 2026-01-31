import '../database.dart';

class ComplianceChecklistsTable extends SupabaseTable<ComplianceChecklistsRow> {
  @override
  String get tableName => 'compliance_checklists';

  @override
  ComplianceChecklistsRow createRow(Map<String, dynamic> data) =>
      ComplianceChecklistsRow(data);
}

class ComplianceChecklistsRow extends SupabaseDataRow {
  ComplianceChecklistsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ComplianceChecklistsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get checklistName => getField<String>('checklist_name')!;
  set checklistName(String value) => setField<String>('checklist_name', value);

  String get checklistType => getField<String>('checklist_type')!;
  set checklistType(String value) => setField<String>('checklist_type', value);

  String? get module => getField<String>('module');
  set module(String? value) => setField<String>('module', value);

  dynamic get items => getField<dynamic>('items')!;
  set items(dynamic value) => setField<dynamic>('items', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime get effectiveFrom => getField<DateTime>('effective_from')!;
  set effectiveFrom(DateTime value) =>
      setField<DateTime>('effective_from', value);

  DateTime? get effectiveTo => getField<DateTime>('effective_to');
  set effectiveTo(DateTime? value) => setField<DateTime>('effective_to', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
