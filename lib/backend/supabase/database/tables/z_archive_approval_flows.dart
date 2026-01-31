import '../database.dart';

class ZArchiveApprovalFlowsTable
    extends SupabaseTable<ZArchiveApprovalFlowsRow> {
  @override
  String get tableName => 'z_archive_approval_flows';

  @override
  ZArchiveApprovalFlowsRow createRow(Map<String, dynamic> data) =>
      ZArchiveApprovalFlowsRow(data);
}

class ZArchiveApprovalFlowsRow extends SupabaseDataRow {
  ZArchiveApprovalFlowsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveApprovalFlowsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get moduleKey => getField<String>('module_key')!;
  set moduleKey(String value) => setField<String>('module_key', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  dynamic get thresholdRules => getField<dynamic>('threshold_rules');
  set thresholdRules(dynamic value) =>
      setField<dynamic>('threshold_rules', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
