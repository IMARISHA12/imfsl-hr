import '../database.dart';

class MvExecCollectionsDisbursementsTable
    extends SupabaseTable<MvExecCollectionsDisbursementsRow> {
  @override
  String get tableName => 'mv_exec_collections_disbursements';

  @override
  MvExecCollectionsDisbursementsRow createRow(Map<String, dynamic> data) =>
      MvExecCollectionsDisbursementsRow(data);
}

class MvExecCollectionsDisbursementsRow extends SupabaseDataRow {
  MvExecCollectionsDisbursementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MvExecCollectionsDisbursementsTable();

  DateTime? get day => getField<DateTime>('day');
  set day(DateTime? value) => setField<DateTime>('day', value);

  double? get collections => getField<double>('collections');
  set collections(double? value) => setField<double>('collections', value);

  double? get disbursed => getField<double>('disbursed');
  set disbursed(double? value) => setField<double>('disbursed', value);
}
