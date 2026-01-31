import '../database.dart';

class ComplianceDocumentsTable extends SupabaseTable<ComplianceDocumentsRow> {
  @override
  String get tableName => 'compliance_documents';

  @override
  ComplianceDocumentsRow createRow(Map<String, dynamic> data) =>
      ComplianceDocumentsRow(data);
}

class ComplianceDocumentsRow extends SupabaseDataRow {
  ComplianceDocumentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ComplianceDocumentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get itemId => getField<String>('item_id');
  set itemId(String? value) => setField<String>('item_id', value);

  String? get docType => getField<String>('doc_type');
  set docType(String? value) => setField<String>('doc_type', value);

  String get fileUrl => getField<String>('file_url')!;
  set fileUrl(String value) => setField<String>('file_url', value);

  String? get uploadedBy => getField<String>('uploaded_by');
  set uploadedBy(String? value) => setField<String>('uploaded_by', value);

  DateTime? get uploadedAt => getField<DateTime>('uploaded_at');
  set uploadedAt(DateTime? value) => setField<DateTime>('uploaded_at', value);

  String? get checksum => getField<String>('checksum');
  set checksum(String? value) => setField<String>('checksum', value);
}
