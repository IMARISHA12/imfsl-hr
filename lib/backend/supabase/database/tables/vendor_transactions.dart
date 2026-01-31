import '../database.dart';

class VendorTransactionsTable extends SupabaseTable<VendorTransactionsRow> {
  @override
  String get tableName => 'vendor_transactions';

  @override
  VendorTransactionsRow createRow(Map<String, dynamic> data) =>
      VendorTransactionsRow(data);
}

class VendorTransactionsRow extends SupabaseDataRow {
  VendorTransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorTransactionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get vendorId => getField<String>('vendor_id')!;
  set vendorId(String value) => setField<String>('vendor_id', value);

  String get transactionType => getField<String>('transaction_type')!;
  set transactionType(String value) =>
      setField<String>('transaction_type', value);

  String? get referenceNumber => getField<String>('reference_number');
  set referenceNumber(String? value) =>
      setField<String>('reference_number', value);

  DateTime get orderDate => getField<DateTime>('order_date')!;
  set orderDate(DateTime value) => setField<DateTime>('order_date', value);

  DateTime? get expectedDeliveryDate =>
      getField<DateTime>('expected_delivery_date');
  set expectedDeliveryDate(DateTime? value) =>
      setField<DateTime>('expected_delivery_date', value);

  DateTime? get actualDeliveryDate =>
      getField<DateTime>('actual_delivery_date');
  set actualDeliveryDate(DateTime? value) =>
      setField<DateTime>('actual_delivery_date', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  bool? get deliveryOnTime => getField<bool>('delivery_on_time');
  set deliveryOnTime(bool? value) => setField<bool>('delivery_on_time', value);

  int? get qualityRating => getField<int>('quality_rating');
  set qualityRating(int? value) => setField<int>('quality_rating', value);

  String? get qualityNotes => getField<String>('quality_notes');
  set qualityNotes(String? value) => setField<String>('quality_notes', value);

  bool? get hasIssues => getField<bool>('has_issues');
  set hasIssues(bool? value) => setField<bool>('has_issues', value);

  String? get issueDescription => getField<String>('issue_description');
  set issueDescription(String? value) =>
      setField<String>('issue_description', value);

  bool? get issueResolved => getField<bool>('issue_resolved');
  set issueResolved(bool? value) => setField<bool>('issue_resolved', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get recordedBy => getField<String>('recorded_by');
  set recordedBy(String? value) => setField<String>('recorded_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
