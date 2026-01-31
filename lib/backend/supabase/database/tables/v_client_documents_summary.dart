import '../database.dart';

class VClientDocumentsSummaryTable
    extends SupabaseTable<VClientDocumentsSummaryRow> {
  @override
  String get tableName => 'v_client_documents_summary';

  @override
  VClientDocumentsSummaryRow createRow(Map<String, dynamic> data) =>
      VClientDocumentsSummaryRow(data);
}

class VClientDocumentsSummaryRow extends SupabaseDataRow {
  VClientDocumentsSummaryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VClientDocumentsSummaryTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get clientId => getField<String>('client_id');
  set clientId(String? value) => setField<String>('client_id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get documentType => getField<String>('document_type');
  set documentType(String? value) => setField<String>('document_type', value);

  String? get documentName => getField<String>('document_name');
  set documentName(String? value) => setField<String>('document_name', value);

  String? get fileUrl => getField<String>('file_url');
  set fileUrl(String? value) => setField<String>('file_url', value);

  String? get verificationStatus => getField<String>('verification_status');
  set verificationStatus(String? value) =>
      setField<String>('verification_status', value);

  String? get verifiedByName => getField<String>('verified_by_name');
  set verifiedByName(String? value) =>
      setField<String>('verified_by_name', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get clientName => getField<String>('client_name');
  set clientName(String? value) => setField<String>('client_name', value);

  String? get expiryStatus => getField<String>('expiry_status');
  set expiryStatus(String? value) => setField<String>('expiry_status', value);
}
