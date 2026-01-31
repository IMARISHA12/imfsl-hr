import '../database.dart';

class MvExecParSignalTable extends SupabaseTable<MvExecParSignalRow> {
  @override
  String get tableName => 'mv_exec_par_signal';

  @override
  MvExecParSignalRow createRow(Map<String, dynamic> data) =>
      MvExecParSignalRow(data);
}

class MvExecParSignalRow extends SupabaseDataRow {
  MvExecParSignalRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MvExecParSignalTable();

  double? get par30Amount => getField<double>('par_30_amount');
  set par30Amount(double? value) => setField<double>('par_30_amount', value);

  double? get totalOutstanding => getField<double>('total_outstanding');
  set totalOutstanding(double? value) =>
      setField<double>('total_outstanding', value);

  double? get par30Pct => getField<double>('par_30_pct');
  set par30Pct(double? value) => setField<double>('par_30_pct', value);
}
