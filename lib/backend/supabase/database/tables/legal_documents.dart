import '../database.dart';

class LegalDocumentsTable extends SupabaseTable<LegalDocumentsRow> {
  @override
  String get tableName => 'legal_documents';

  @override
  LegalDocumentsRow createRow(Map<String, dynamic> data) =>
      LegalDocumentsRow(data);
}

class LegalDocumentsRow extends SupabaseDataRow {
  LegalDocumentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalDocumentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get documentType => getField<String>('document_type');
  set documentType(String? value) => setField<String>('document_type', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get filePath => getField<String>('file_path')!;
  set filePath(String value) => setField<String>('file_path', value);

  String get fileName => getField<String>('file_name')!;
  set fileName(String value) => setField<String>('file_name', value);

  int? get fileSize => getField<int>('file_size');
  set fileSize(int? value) => setField<int>('file_size', value);

  String? get mimeType => getField<String>('mime_type');
  set mimeType(String? value) => setField<String>('mime_type', value);

  int? get version => getField<int>('version');
  set version(int? value) => setField<int>('version', value);

  String? get extractionStatus => getField<String>('extraction_status');
  set extractionStatus(String? value) =>
      setField<String>('extraction_status', value);

  String? get extractedText => getField<String>('extracted_text');
  set extractedText(String? value) => setField<String>('extracted_text', value);

  String? get summary => getField<String>('summary');
  set summary(String? value) => setField<String>('summary', value);

  dynamic get keyClauses => getField<dynamic>('key_clauses');
  set keyClauses(dynamic value) => setField<dynamic>('key_clauses', value);

  dynamic get riskFlags => getField<dynamic>('risk_flags');
  set riskFlags(dynamic value) => setField<dynamic>('risk_flags', value);

  DateTime? get effectiveDate => getField<DateTime>('effective_date');
  set effectiveDate(DateTime? value) =>
      setField<DateTime>('effective_date', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  List<String> get partiesInvolved => getListField<String>('parties_involved');
  set partiesInvolved(List<String>? value) =>
      setListField<String>('parties_involved', value);

  List<String> get relatedDocuments =>
      getListField<String>('related_documents');
  set relatedDocuments(List<String>? value) =>
      setListField<String>('related_documents', value);

  List<String> get tags => getListField<String>('tags');
  set tags(List<String>? value) => setListField<String>('tags', value);

  String? get uploadedBy => getField<String>('uploaded_by');
  set uploadedBy(String? value) => setField<String>('uploaded_by', value);

  bool? get isConfidential => getField<bool>('is_confidential');
  set isConfidential(bool? value) => setField<bool>('is_confidential', value);

  String? get accessLevel => getField<String>('access_level');
  set accessLevel(String? value) => setField<String>('access_level', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  DateTime? get lastAccessedAt => getField<DateTime>('last_accessed_at');
  set lastAccessedAt(DateTime? value) =>
      setField<DateTime>('last_accessed_at', value);

  int? get accessCount => getField<int>('access_count');
  set accessCount(int? value) => setField<int>('access_count', value);
}
