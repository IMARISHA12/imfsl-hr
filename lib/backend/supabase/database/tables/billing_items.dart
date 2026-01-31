import '../database.dart';

class BillingItemsTable extends SupabaseTable<BillingItemsRow> {
  @override
  String get tableName => 'billing_items';

  @override
  BillingItemsRow createRow(Map<String, dynamic> data) => BillingItemsRow(data);
}

class BillingItemsRow extends SupabaseDataRow {
  BillingItemsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BillingItemsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get ownerEntity => getField<String>('owner_entity')!;
  set ownerEntity(String value) => setField<String>('owner_entity', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String? get vendorName => getField<String>('vendor_name');
  set vendorName(String? value) => setField<String>('vendor_name', value);

  String? get vendorContact => getField<String>('vendor_contact');
  set vendorContact(String? value) => setField<String>('vendor_contact', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String get billingCycle => getField<String>('billing_cycle')!;
  set billingCycle(String value) => setField<String>('billing_cycle', value);

  DateTime get nextDueDate => getField<DateTime>('next_due_date')!;
  set nextDueDate(DateTime value) => setField<DateTime>('next_due_date', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get responsibleRole => getField<String>('responsible_role')!;
  set responsibleRole(String value) =>
      setField<String>('responsible_role', value);

  bool? get autoRenew => getField<bool>('auto_renew');
  set autoRenew(bool? value) => setField<bool>('auto_renew', value);

  String? get paymentMethod => getField<String>('payment_method');
  set paymentMethod(String? value) => setField<String>('payment_method', value);

  String? get referenceNumber => getField<String>('reference_number');
  set referenceNumber(String? value) =>
      setField<String>('reference_number', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
