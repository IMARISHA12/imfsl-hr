import '../database.dart';

class VendorQuotesTable extends SupabaseTable<VendorQuotesRow> {
  @override
  String get tableName => 'vendor_quotes';

  @override
  VendorQuotesRow createRow(Map<String, dynamic> data) => VendorQuotesRow(data);
}

class VendorQuotesRow extends SupabaseDataRow {
  VendorQuotesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorQuotesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get requisitionId => getField<String>('requisition_id');
  set requisitionId(String? value) => setField<String>('requisition_id', value);

  String get vendorId => getField<String>('vendor_id')!;
  set vendorId(String value) => setField<String>('vendor_id', value);

  String? get quoteRef => getField<String>('quote_ref');
  set quoteRef(String? value) => setField<String>('quote_ref', value);

  DateTime get quoteDate => getField<DateTime>('quote_date')!;
  set quoteDate(DateTime value) => setField<DateTime>('quote_date', value);

  DateTime? get validUntil => getField<DateTime>('valid_until');
  set validUntil(DateTime? value) => setField<DateTime>('valid_until', value);

  double get quotedAmount => getField<double>('quoted_amount')!;
  set quotedAmount(double value) => setField<double>('quoted_amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  int? get deliveryDays => getField<int>('delivery_days');
  set deliveryDays(int? value) => setField<int>('delivery_days', value);

  String? get paymentTerms => getField<String>('payment_terms');
  set paymentTerms(String? value) => setField<String>('payment_terms', value);

  String? get warrantyTerms => getField<String>('warranty_terms');
  set warrantyTerms(String? value) => setField<String>('warranty_terms', value);

  double? get technicalScore => getField<double>('technical_score');
  set technicalScore(double? value) =>
      setField<double>('technical_score', value);

  double? get priceScore => getField<double>('price_score');
  set priceScore(double? value) => setField<double>('price_score', value);

  double? get overallScore => getField<double>('overall_score');
  set overallScore(double? value) => setField<double>('overall_score', value);

  String? get evaluationNotes => getField<String>('evaluation_notes');
  set evaluationNotes(String? value) =>
      setField<String>('evaluation_notes', value);

  bool? get isSelected => getField<bool>('is_selected');
  set isSelected(bool? value) => setField<bool>('is_selected', value);

  String? get selectedBy => getField<String>('selected_by');
  set selectedBy(String? value) => setField<String>('selected_by', value);

  DateTime? get selectedAt => getField<DateTime>('selected_at');
  set selectedAt(DateTime? value) => setField<DateTime>('selected_at', value);

  String? get selectionReason => getField<String>('selection_reason');
  set selectionReason(String? value) =>
      setField<String>('selection_reason', value);

  String? get quoteDocumentUrl => getField<String>('quote_document_url');
  set quoteDocumentUrl(String? value) =>
      setField<String>('quote_document_url', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
