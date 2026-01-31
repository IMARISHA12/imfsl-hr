import '../database.dart';

class ClientDocumentsTable extends SupabaseTable<ClientDocumentsRow> {
  @override
  String get tableName => 'client_documents';

  @override
  ClientDocumentsRow createRow(Map<String, dynamic> data) =>
      ClientDocumentsRow(data);
}

class ClientDocumentsRow extends SupabaseDataRow {
  ClientDocumentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClientDocumentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String get documentType => getField<String>('document_type')!;
  set documentType(String value) => setField<String>('document_type', value);

  String get documentName => getField<String>('document_name')!;
  set documentName(String value) => setField<String>('document_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get fileUrl => getField<String>('file_url')!;
  set fileUrl(String value) => setField<String>('file_url', value);

  String get fileName => getField<String>('file_name')!;
  set fileName(String value) => setField<String>('file_name', value);

  int? get fileSize => getField<int>('file_size');
  set fileSize(int? value) => setField<int>('file_size', value);

  String? get mimeType => getField<String>('mime_type');
  set mimeType(String? value) => setField<String>('mime_type', value);

  String get verificationStatus => getField<String>('verification_status')!;
  set verificationStatus(String value) =>
      setField<String>('verification_status', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  String? get verifiedByName => getField<String>('verified_by_name');
  set verifiedByName(String? value) =>
      setField<String>('verified_by_name', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  DateTime? get issueDate => getField<DateTime>('issue_date');
  set issueDate(DateTime? value) => setField<DateTime>('issue_date', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  String? get documentNumber => getField<String>('document_number');
  set documentNumber(String? value) =>
      setField<String>('document_number', value);

  String? get uploadedBy => getField<String>('uploaded_by');
  set uploadedBy(String? value) => setField<String>('uploaded_by', value);

  String? get uploadedByName => getField<String>('uploaded_by_name');
  set uploadedByName(String? value) =>
      setField<String>('uploaded_by_name', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
