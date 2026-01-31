import '../database.dart';

class ForensicRecoveryCostsTable
    extends SupabaseTable<ForensicRecoveryCostsRow> {
  @override
  String get tableName => 'forensic_recovery_costs';

  @override
  ForensicRecoveryCostsRow createRow(Map<String, dynamic> data) =>
      ForensicRecoveryCostsRow(data);
}

class ForensicRecoveryCostsRow extends SupabaseDataRow {
  ForensicRecoveryCostsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ForensicRecoveryCostsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String get costType => getField<String>('cost_type')!;
  set costType(String value) => setField<String>('cost_type', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  DateTime get incurredAt => getField<DateTime>('incurred_at')!;
  set incurredAt(DateTime value) => setField<DateTime>('incurred_at', value);

  String? get vendorId => getField<String>('vendor_id');
  set vendorId(String? value) => setField<String>('vendor_id', value);

  String? get arId => getField<String>('ar_id');
  set arId(String? value) => setField<String>('ar_id', value);

  String? get journalId => getField<String>('journal_id');
  set journalId(String? value) => setField<String>('journal_id', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
