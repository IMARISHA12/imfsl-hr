import '../database.dart';

class EmployeeDocumentsTable extends SupabaseTable<EmployeeDocumentsRow> {
  @override
  String get tableName => 'employee_documents';

  @override
  EmployeeDocumentsRow createRow(Map<String, dynamic> data) =>
      EmployeeDocumentsRow(data);
}

class EmployeeDocumentsRow extends SupabaseDataRow {
  EmployeeDocumentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EmployeeDocumentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get documentType => getField<String>('document_type')!;
  set documentType(String value) => setField<String>('document_type', value);

  String get fileName => getField<String>('file_name')!;
  set fileName(String value) => setField<String>('file_name', value);

  String get filePath => getField<String>('file_path')!;
  set filePath(String value) => setField<String>('file_path', value);

  int? get fileSize => getField<int>('file_size');
  set fileSize(int? value) => setField<int>('file_size', value);

  String? get contentType => getField<String>('content_type');
  set contentType(String? value) => setField<String>('content_type', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  bool? get isVerified => getField<bool>('is_verified');
  set isVerified(bool? value) => setField<bool>('is_verified', value);

  DateTime? get uploadedAt => getField<DateTime>('uploaded_at');
  set uploadedAt(DateTime? value) => setField<DateTime>('uploaded_at', value);
}
