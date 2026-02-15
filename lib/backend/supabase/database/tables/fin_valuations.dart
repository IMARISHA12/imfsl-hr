import '../database.dart';

class FinValuationsTable extends SupabaseTable<FinValuationsRow> {
  @override
  String get tableName => 'fin_valuations';

  @override
  FinValuationsRow createRow(Map<String, dynamic> data) =>
      FinValuationsRow(data);
}

class FinValuationsRow extends SupabaseDataRow {
  FinValuationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FinValuationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get vehicleId => getField<String>('vehicle_id');
  set vehicleId(String? value) => setField<String>('vehicle_id', value);

  DateTime? get valuationDate => getField<DateTime>('valuation_date');
  set valuationDate(DateTime? value) =>
      setField<DateTime>('valuation_date', value);

  String? get valuerCompany => getField<String>('valuer_company');
  set valuerCompany(String? value) => setField<String>('valuer_company', value);

  double get marketValue => getField<double>('market_value')!;
  set marketValue(double value) => setField<double>('market_value', value);

  double get forcedSaleValue => getField<double>('forced_sale_value')!;
  set forcedSaleValue(double value) =>
      setField<double>('forced_sale_value', value);

  double? get maxLoanableAmount => getField<double>('max_loanable_amount');
  set maxLoanableAmount(double? value) =>
      setField<double>('max_loanable_amount', value);

  String? get reportFileUrl => getField<String>('report_file_url');
  set reportFileUrl(String? value) =>
      setField<String>('report_file_url', value);
}
