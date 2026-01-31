import '../database.dart';

class KpiAssignmentsTable extends SupabaseTable<KpiAssignmentsRow> {
  @override
  String get tableName => 'kpi_assignments';

  @override
  KpiAssignmentsRow createRow(Map<String, dynamic> data) =>
      KpiAssignmentsRow(data);
}

class KpiAssignmentsRow extends SupabaseDataRow {
  KpiAssignmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => KpiAssignmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  String get periodId => getField<String>('period_id')!;
  set periodId(String value) => setField<String>('period_id', value);

  int get totalWeight => getField<int>('total_weight')!;
  set totalWeight(int value) => setField<int>('total_weight', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
