import '../database.dart';

class ZArchiveBillingCategoriesTable
    extends SupabaseTable<ZArchiveBillingCategoriesRow> {
  @override
  String get tableName => 'z_archive_billing_categories';

  @override
  ZArchiveBillingCategoriesRow createRow(Map<String, dynamic> data) =>
      ZArchiveBillingCategoriesRow(data);
}

class ZArchiveBillingCategoriesRow extends SupabaseDataRow {
  ZArchiveBillingCategoriesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveBillingCategoriesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get categoryCode => getField<String>('category_code')!;
  set categoryCode(String value) => setField<String>('category_code', value);

  String get categoryName => getField<String>('category_name')!;
  set categoryName(String value) => setField<String>('category_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
