import '../database.dart';

class CollectionsTable extends SupabaseTable<CollectionsRow> {
  @override
  String get tableName => 'collections';

  @override
  CollectionsRow createRow(Map<String, dynamic> data) => CollectionsRow(data);
}

class CollectionsRow extends SupabaseDataRow {
  CollectionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get customerId => getField<String>('customer_id')!;
  set customerId(String value) => setField<String>('customer_id', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String get collectedBy => getField<String>('collected_by')!;
  set collectedBy(String value) => setField<String>('collected_by', value);

  String? get organizationId => getField<String>('organization_id');
  set organizationId(String? value) =>
      setField<String>('organization_id', value);

  DateTime get collectedAt => getField<DateTime>('collected_at')!;
  set collectedAt(DateTime value) => setField<DateTime>('collected_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
