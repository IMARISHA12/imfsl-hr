import '../database.dart';

class VendorStatementReconciliationsTable
    extends SupabaseTable<VendorStatementReconciliationsRow> {
  @override
  String get tableName => 'vendor_statement_reconciliations';

  @override
  VendorStatementReconciliationsRow createRow(Map<String, dynamic> data) =>
      VendorStatementReconciliationsRow(data);
}

class VendorStatementReconciliationsRow extends SupabaseDataRow {
  VendorStatementReconciliationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorStatementReconciliationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get vendorId => getField<String>('vendor_id')!;
  set vendorId(String value) => setField<String>('vendor_id', value);

  String? get periodId => getField<String>('period_id');
  set periodId(String? value) => setField<String>('period_id', value);

  DateTime get statementDate => getField<DateTime>('statement_date')!;
  set statementDate(DateTime value) =>
      setField<DateTime>('statement_date', value);

  String? get statementRef => getField<String>('statement_ref');
  set statementRef(String? value) => setField<String>('statement_ref', value);

  double get statementBalance => getField<double>('statement_balance')!;
  set statementBalance(double value) =>
      setField<double>('statement_balance', value);

  double get bookBalance => getField<double>('book_balance')!;
  set bookBalance(double value) => setField<double>('book_balance', value);

  double? get variance => getField<double>('variance');
  set variance(double? value) => setField<double>('variance', value);

  String? get varianceExplanation => getField<String>('variance_explanation');
  set varianceExplanation(String? value) =>
      setField<String>('variance_explanation', value);

  dynamic get unmatchedVendorItems =>
      getField<dynamic>('unmatched_vendor_items');
  set unmatchedVendorItems(dynamic value) =>
      setField<dynamic>('unmatched_vendor_items', value);

  dynamic get unmatchedBookItems => getField<dynamic>('unmatched_book_items');
  set unmatchedBookItems(dynamic value) =>
      setField<dynamic>('unmatched_book_items', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get preparedBy => getField<String>('prepared_by');
  set preparedBy(String? value) => setField<String>('prepared_by', value);

  DateTime? get preparedAt => getField<DateTime>('prepared_at');
  set preparedAt(DateTime? value) => setField<DateTime>('prepared_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  List<String> get evidenceUrls => getListField<String>('evidence_urls');
  set evidenceUrls(List<String>? value) =>
      setListField<String>('evidence_urls', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
