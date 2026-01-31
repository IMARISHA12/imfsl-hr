import '../database.dart';

class PurchaseRequisitionsTable extends SupabaseTable<PurchaseRequisitionsRow> {
  @override
  String get tableName => 'purchase_requisitions';

  @override
  PurchaseRequisitionsRow createRow(Map<String, dynamic> data) =>
      PurchaseRequisitionsRow(data);
}

class PurchaseRequisitionsRow extends SupabaseDataRow {
  PurchaseRequisitionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PurchaseRequisitionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get requisitionNo => getField<String>('requisition_no')!;
  set requisitionNo(String value) => setField<String>('requisition_no', value);

  String get requestedBy => getField<String>('requested_by')!;
  set requestedBy(String value) => setField<String>('requested_by', value);

  String? get departmentId => getField<String>('department_id');
  set departmentId(String? value) => setField<String>('department_id', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String? get justification => getField<String>('justification');
  set justification(String? value) => setField<String>('justification', value);

  double get estimatedAmount => getField<double>('estimated_amount')!;
  set estimatedAmount(double value) =>
      setField<double>('estimated_amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get budgetCode => getField<String>('budget_code');
  set budgetCode(String? value) => setField<String>('budget_code', value);

  double? get budgetAvailable => getField<double>('budget_available');
  set budgetAvailable(double? value) =>
      setField<double>('budget_available', value);

  String? get preferredVendorId => getField<String>('preferred_vendor_id');
  set preferredVendorId(String? value) =>
      setField<String>('preferred_vendor_id', value);

  String? get priority => getField<String>('priority');
  set priority(String? value) => setField<String>('priority', value);

  DateTime? get requiredBy => getField<DateTime>('required_by');
  set requiredBy(DateTime? value) => setField<DateTime>('required_by', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) => setField<DateTime>('submitted_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get rejectedBy => getField<String>('rejected_by');
  set rejectedBy(String? value) => setField<String>('rejected_by', value);

  DateTime? get rejectedAt => getField<DateTime>('rejected_at');
  set rejectedAt(DateTime? value) => setField<DateTime>('rejected_at', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  String? get purchaseOrderId => getField<String>('purchase_order_id');
  set purchaseOrderId(String? value) =>
      setField<String>('purchase_order_id', value);

  DateTime? get convertedAt => getField<DateTime>('converted_at');
  set convertedAt(DateTime? value) => setField<DateTime>('converted_at', value);

  List<String> get attachmentUrls => getListField<String>('attachment_urls');
  set attachmentUrls(List<String>? value) =>
      setListField<String>('attachment_urls', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
