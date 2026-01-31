import '../database.dart';

class AuditPartitionStatusTable extends SupabaseTable<AuditPartitionStatusRow> {
  @override
  String get tableName => 'audit_partition_status';

  @override
  AuditPartitionStatusRow createRow(Map<String, dynamic> data) =>
      AuditPartitionStatusRow(data);
}

class AuditPartitionStatusRow extends SupabaseDataRow {
  AuditPartitionStatusRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AuditPartitionStatusTable();

  String? get schemaname => getField<String>('schemaname');
  set schemaname(String? value) => setField<String>('schemaname', value);

  String? get partitionName => getField<String>('partition_name');
  set partitionName(String? value) => setField<String>('partition_name', value);

  String? get partitionSize => getField<String>('partition_size');
  set partitionSize(String? value) => setField<String>('partition_size', value);

  String? get monthKey => getField<String>('month_key');
  set monthKey(String? value) => setField<String>('month_key', value);
}
