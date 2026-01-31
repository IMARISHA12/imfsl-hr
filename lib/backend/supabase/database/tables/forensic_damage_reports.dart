import '../database.dart';

class ForensicDamageReportsTable
    extends SupabaseTable<ForensicDamageReportsRow> {
  @override
  String get tableName => 'forensic_damage_reports';

  @override
  ForensicDamageReportsRow createRow(Map<String, dynamic> data) =>
      ForensicDamageReportsRow(data);
}

class ForensicDamageReportsRow extends SupabaseDataRow {
  ForensicDamageReportsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ForensicDamageReportsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String get stage => getField<String>('stage')!;
  set stage(String value) => setField<String>('stage', value);

  bool get damageReported => getField<bool>('damage_reported')!;
  set damageReported(bool value) => setField<bool>('damage_reported', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String get reportedBy => getField<String>('reported_by')!;
  set reportedBy(String value) => setField<String>('reported_by', value);

  DateTime get reportedAt => getField<DateTime>('reported_at')!;
  set reportedAt(DateTime value) => setField<DateTime>('reported_at', value);
}
