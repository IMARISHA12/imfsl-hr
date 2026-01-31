import '../database.dart';

class CollateralsTable extends SupabaseTable<CollateralsRow> {
  @override
  String get tableName => 'collaterals';

  @override
  CollateralsRow createRow(Map<String, dynamic> data) => CollateralsRow(data);
}

class CollateralsRow extends SupabaseDataRow {
  CollateralsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollateralsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get collateralType => getField<String>('collateral_type')!;
  set collateralType(String value) =>
      setField<String>('collateral_type', value);

  dynamic get details => getField<dynamic>('details')!;
  set details(dynamic value) => setField<dynamic>('details', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
