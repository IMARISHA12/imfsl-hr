import '../database.dart';

class GlPeriodTransitionsTable extends SupabaseTable<GlPeriodTransitionsRow> {
  @override
  String get tableName => 'gl_period_transitions';

  @override
  GlPeriodTransitionsRow createRow(Map<String, dynamic> data) =>
      GlPeriodTransitionsRow(data);
}

class GlPeriodTransitionsRow extends SupabaseDataRow {
  GlPeriodTransitionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GlPeriodTransitionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get periodId => getField<String>('period_id')!;
  set periodId(String value) => setField<String>('period_id', value);

  String? get fromStatus => getField<String>('from_status');
  set fromStatus(String? value) => setField<String>('from_status', value);

  String get toStatus => getField<String>('to_status')!;
  set toStatus(String value) => setField<String>('to_status', value);

  String? get transitionedBy => getField<String>('transitioned_by');
  set transitionedBy(String? value) =>
      setField<String>('transitioned_by', value);

  DateTime get transitionedAt => getField<DateTime>('transitioned_at')!;
  set transitionedAt(DateTime value) =>
      setField<DateTime>('transitioned_at', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  List<String> get evidenceUrls => getListField<String>('evidence_urls');
  set evidenceUrls(List<String>? value) =>
      setListField<String>('evidence_urls', value);

  dynamic get checklistSnapshot => getField<dynamic>('checklist_snapshot');
  set checklistSnapshot(dynamic value) =>
      setField<dynamic>('checklist_snapshot', value);
}
