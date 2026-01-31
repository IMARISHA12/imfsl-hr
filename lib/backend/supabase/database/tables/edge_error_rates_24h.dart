import '../database.dart';

class EdgeErrorRates24hTable extends SupabaseTable<EdgeErrorRates24hRow> {
  @override
  String get tableName => 'edge_error_rates_24h';

  @override
  EdgeErrorRates24hRow createRow(Map<String, dynamic> data) =>
      EdgeErrorRates24hRow(data);
}

class EdgeErrorRates24hRow extends SupabaseDataRow {
  EdgeErrorRates24hRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EdgeErrorRates24hTable();

  String? get functionName => getField<String>('function_name');
  set functionName(String? value) => setField<String>('function_name', value);

  int? get total => getField<int>('total');
  set total(int? value) => setField<int>('total', value);

  int? get errors => getField<int>('errors');
  set errors(int? value) => setField<int>('errors', value);

  double? get errorRatePct => getField<double>('error_rate_pct');
  set errorRatePct(double? value) => setField<double>('error_rate_pct', value);

  DateTime? get computedAt => getField<DateTime>('computed_at');
  set computedAt(DateTime? value) => setField<DateTime>('computed_at', value);
}
