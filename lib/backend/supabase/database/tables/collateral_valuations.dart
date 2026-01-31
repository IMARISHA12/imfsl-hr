import '../database.dart';

class CollateralValuationsTable extends SupabaseTable<CollateralValuationsRow> {
  @override
  String get tableName => 'collateral_valuations';

  @override
  CollateralValuationsRow createRow(Map<String, dynamic> data) =>
      CollateralValuationsRow(data);
}

class CollateralValuationsRow extends SupabaseDataRow {
  CollateralValuationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollateralValuationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get collateralId => getField<String>('collateral_id')!;
  set collateralId(String value) => setField<String>('collateral_id', value);

  double get estimatedValue => getField<double>('estimated_value')!;
  set estimatedValue(double value) =>
      setField<double>('estimated_value', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  DateTime get valuationDate => getField<DateTime>('valuation_date')!;
  set valuationDate(DateTime value) =>
      setField<DateTime>('valuation_date', value);

  String? get valuatedBy => getField<String>('valuated_by');
  set valuatedBy(String? value) => setField<String>('valuated_by', value);

  String? get valuationMethod => getField<String>('valuation_method');
  set valuationMethod(String? value) =>
      setField<String>('valuation_method', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get documentUrl => getField<String>('document_url');
  set documentUrl(String? value) => setField<String>('document_url', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get createdByName => getField<String>('created_by_name');
  set createdByName(String? value) =>
      setField<String>('created_by_name', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
