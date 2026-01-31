import '../database.dart';

class ZArchiveTamperEvidentAuditTable
    extends SupabaseTable<ZArchiveTamperEvidentAuditRow> {
  @override
  String get tableName => 'z_archive_tamper_evident_audit';

  @override
  ZArchiveTamperEvidentAuditRow createRow(Map<String, dynamic> data) =>
      ZArchiveTamperEvidentAuditRow(data);
}

class ZArchiveTamperEvidentAuditRow extends SupabaseDataRow {
  ZArchiveTamperEvidentAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveTamperEvidentAuditTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get tableNameField => getField<String>('table_name')!;
  set tableNameField(String value) => setField<String>('table_name', value);

  String get recordId => getField<String>('record_id')!;
  set recordId(String value) => setField<String>('record_id', value);

  dynamic get recordData => getField<dynamic>('record_data')!;
  set recordData(dynamic value) => setField<dynamic>('record_data', value);

  String? get actorId => getField<String>('actor_id');
  set actorId(String? value) => setField<String>('actor_id', value);

  String get chainHash => getField<String>('chain_hash')!;
  set chainHash(String value) => setField<String>('chain_hash', value);

  String? get previousHash => getField<String>('previous_hash');
  set previousHash(String? value) => setField<String>('previous_hash', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
