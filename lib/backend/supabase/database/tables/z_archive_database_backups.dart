import '../database.dart';

class ZArchiveDatabaseBackupsTable
    extends SupabaseTable<ZArchiveDatabaseBackupsRow> {
  @override
  String get tableName => 'z_archive_database_backups';

  @override
  ZArchiveDatabaseBackupsRow createRow(Map<String, dynamic> data) =>
      ZArchiveDatabaseBackupsRow(data);
}

class ZArchiveDatabaseBackupsRow extends SupabaseDataRow {
  ZArchiveDatabaseBackupsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveDatabaseBackupsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get backupType => getField<String>('backup_type')!;
  set backupType(String value) => setField<String>('backup_type', value);

  String get backupStatus => getField<String>('backup_status')!;
  set backupStatus(String value) => setField<String>('backup_status', value);

  String get storagePath => getField<String>('storage_path')!;
  set storagePath(String value) => setField<String>('storage_path', value);

  int? get backupSizeBytes => getField<int>('backup_size_bytes');
  set backupSizeBytes(int? value) => setField<int>('backup_size_bytes', value);

  String? get backupHash => getField<String>('backup_hash');
  set backupHash(String? value) => setField<String>('backup_hash', value);

  String? get encryptionKeyId => getField<String>('encryption_key_id');
  set encryptionKeyId(String? value) =>
      setField<String>('encryption_key_id', value);

  DateTime get startedAt => getField<DateTime>('started_at')!;
  set startedAt(DateTime value) => setField<DateTime>('started_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);

  DateTime get expiresAt => getField<DateTime>('expires_at')!;
  set expiresAt(DateTime value) => setField<DateTime>('expires_at', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
