import '../database.dart';

class VendorsTable extends SupabaseTable<VendorsRow> {
  @override
  String get tableName => 'vendors';

  @override
  VendorsRow createRow(Map<String, dynamic> data) => VendorsRow(data);
}

class VendorsRow extends SupabaseDataRow {
  VendorsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VendorsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get vendorName => getField<String>('vendor_name')!;
  set vendorName(String value) => setField<String>('vendor_name', value);

  String? get serviceType => getField<String>('service_type');
  set serviceType(String? value) => setField<String>('service_type', value);

  String? get contactPerson => getField<String>('contact_person');
  set contactPerson(String? value) => setField<String>('contact_person', value);

  String? get contactEmail => getField<String>('contact_email');
  set contactEmail(String? value) => setField<String>('contact_email', value);

  String? get contactPhone => getField<String>('contact_phone');
  set contactPhone(String? value) => setField<String>('contact_phone', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get logoUrl => getField<String>('logo_url');
  set logoUrl(String? value) => setField<String>('logo_url', value);

  String? get profileDocumentUrl => getField<String>('profile_document_url');
  set profileDocumentUrl(String? value) =>
      setField<String>('profile_document_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get vendorCode => getField<String>('vendor_code');
  set vendorCode(String? value) => setField<String>('vendor_code', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  int? get paymentTerms => getField<int>('payment_terms');
  set paymentTerms(int? value) => setField<int>('payment_terms', value);

  double? get taxRate => getField<double>('tax_rate');
  set taxRate(double? value) => setField<double>('tax_rate', value);
}
