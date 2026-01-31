import '../database.dart';

class StaffDocumentsTable extends SupabaseTable<StaffDocumentsRow> {
  @override
  String get tableName => 'staff_documents';

  @override
  StaffDocumentsRow createRow(Map<String, dynamic> data) =>
      StaffDocumentsRow(data);
}

class StaffDocumentsRow extends SupabaseDataRow {
  StaffDocumentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffDocumentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  String get documentType => getField<String>('document_type')!;
  set documentType(String value) => setField<String>('document_type', value);

  String get filePath => getField<String>('file_path')!;
  set filePath(String value) => setField<String>('file_path', value);

  String get fileName => getField<String>('file_name')!;
  set fileName(String value) => setField<String>('file_name', value);

  String? get contentType => getField<String>('content_type');
  set contentType(String? value) => setField<String>('content_type', value);

  int? get fileSize => getField<int>('file_size');
  set fileSize(int? value) => setField<int>('file_size', value);

  DateTime get uploadedAt => getField<DateTime>('uploaded_at')!;
  set uploadedAt(DateTime value) => setField<DateTime>('uploaded_at', value);

  String? get uploadedBy => getField<String>('uploaded_by');
  set uploadedBy(String? value) => setField<String>('uploaded_by', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);
}
