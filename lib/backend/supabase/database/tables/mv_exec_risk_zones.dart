import '../database.dart';

class MvExecRiskZonesTable extends SupabaseTable<MvExecRiskZonesRow> {
  @override
  String get tableName => 'mv_exec_risk_zones';

  @override
  MvExecRiskZonesRow createRow(Map<String, dynamic> data) =>
      MvExecRiskZonesRow(data);
}

class MvExecRiskZonesRow extends SupabaseDataRow {
  MvExecRiskZonesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MvExecRiskZonesTable();

  String? get zoneName => getField<String>('zone_name');
  set zoneName(String? value) => setField<String>('zone_name', value);

  String? get region => getField<String>('region');
  set region(String? value) => setField<String>('region', value);

  String? get district => getField<String>('district');
  set district(String? value) => setField<String>('district', value);

  double? get defaultRate => getField<double>('default_rate');
  set defaultRate(double? value) => setField<double>('default_rate', value);

  String? get riskLevel => getField<String>('risk_level');
  set riskLevel(String? value) => setField<String>('risk_level', value);

  int? get totalLoans => getField<int>('total_loans');
  set totalLoans(int? value) => setField<int>('total_loans', value);

  int? get defaultCount => getField<int>('default_count');
  set defaultCount(int? value) => setField<int>('default_count', value);

  DateTime? get lastAnalyzedAt => getField<DateTime>('last_analyzed_at');
  set lastAnalyzedAt(DateTime? value) =>
      setField<DateTime>('last_analyzed_at', value);
}
