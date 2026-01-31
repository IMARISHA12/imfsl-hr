import '../database.dart';

class ViewLiquidityForecastTable
    extends SupabaseTable<ViewLiquidityForecastRow> {
  @override
  String get tableName => 'view_liquidity_forecast';

  @override
  ViewLiquidityForecastRow createRow(Map<String, dynamic> data) =>
      ViewLiquidityForecastRow(data);
}

class ViewLiquidityForecastRow extends SupabaseDataRow {
  ViewLiquidityForecastRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ViewLiquidityForecastTable();

  DateTime? get forecastDate => getField<DateTime>('forecast_date');
  set forecastDate(DateTime? value) =>
      setField<DateTime>('forecast_date', value);

  double? get expectedInflow => getField<double>('expected_inflow');
  set expectedInflow(double? value) =>
      setField<double>('expected_inflow', value);

  double? get expectedOutflow => getField<double>('expected_outflow');
  set expectedOutflow(double? value) =>
      setField<double>('expected_outflow', value);

  double? get netPosition => getField<double>('net_position');
  set netPosition(double? value) => setField<double>('net_position', value);
}
