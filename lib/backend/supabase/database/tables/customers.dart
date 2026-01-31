import '../database.dart';

class CustomersTable extends SupabaseTable<CustomersRow> {
  @override
  String get tableName => 'customers';

  @override
  CustomersRow createRow(Map<String, dynamic> data) => CustomersRow(data);
}

class CustomersRow extends SupabaseDataRow {
  CustomersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CustomersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get customerCode => getField<String>('customer_code')!;
  set customerCode(String value) => setField<String>('customer_code', value);

  String get customerName => getField<String>('customer_name')!;
  set customerName(String value) => setField<String>('customer_name', value);

  String? get contactPerson => getField<String>('contact_person');
  set contactPerson(String? value) => setField<String>('contact_person', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get phone => getField<String>('phone');
  set phone(String? value) => setField<String>('phone', value);

  String? get address => getField<String>('address');
  set address(String? value) => setField<String>('address', value);

  String? get taxId => getField<String>('tax_id');
  set taxId(String? value) => setField<String>('tax_id', value);

  double? get creditLimit => getField<double>('credit_limit');
  set creditLimit(double? value) => setField<double>('credit_limit', value);

  int? get paymentTerms => getField<int>('payment_terms');
  set paymentTerms(int? value) => setField<int>('payment_terms', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get organizationId => getField<String>('organization_id');
  set organizationId(String? value) =>
      setField<String>('organization_id', value);
}
