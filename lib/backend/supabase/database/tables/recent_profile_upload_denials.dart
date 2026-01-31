import '../database.dart';

class RecentProfileUploadDenialsTable
    extends SupabaseTable<RecentProfileUploadDenialsRow> {
  @override
  String get tableName => 'recent_profile_upload_denials';

  @override
  RecentProfileUploadDenialsRow createRow(Map<String, dynamic> data) =>
      RecentProfileUploadDenialsRow(data);
}

class RecentProfileUploadDenialsRow extends SupabaseDataRow {
  RecentProfileUploadDenialsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RecentProfileUploadDenialsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get documentId => getField<String>('document_id');
  set documentId(String? value) => setField<String>('document_id', value);

  String? get action => getField<String>('action');
  set action(String? value) => setField<String>('action', value);

  DateTime? get accessedAt => getField<DateTime>('accessed_at');
  set accessedAt(DateTime? value) => setField<DateTime>('accessed_at', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}
