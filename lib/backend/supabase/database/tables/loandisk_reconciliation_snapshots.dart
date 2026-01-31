import '../database.dart';

class LoandiskReconciliationSnapshotsTable
    extends SupabaseTable<LoandiskReconciliationSnapshotsRow> {
  @override
  String get tableName => 'loandisk_reconciliation_snapshots';

  @override
  LoandiskReconciliationSnapshotsRow createRow(Map<String, dynamic> data) =>
      LoandiskReconciliationSnapshotsRow(data);
}

class LoandiskReconciliationSnapshotsRow extends SupabaseDataRow {
  LoandiskReconciliationSnapshotsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoandiskReconciliationSnapshotsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get reconciliationDate => getField<DateTime>('reconciliation_date')!;
  set reconciliationDate(DateTime value) =>
      setField<DateTime>('reconciliation_date', value);

  DateTime get periodStart => getField<DateTime>('period_start')!;
  set periodStart(DateTime value) => setField<DateTime>('period_start', value);

  DateTime get periodEnd => getField<DateTime>('period_end')!;
  set periodEnd(DateTime value) => setField<DateTime>('period_end', value);

  int? get ldTotalLoans => getField<int>('ld_total_loans');
  set ldTotalLoans(int? value) => setField<int>('ld_total_loans', value);

  double? get ldTotalDisbursed => getField<double>('ld_total_disbursed');
  set ldTotalDisbursed(double? value) =>
      setField<double>('ld_total_disbursed', value);

  double? get ldTotalOutstanding => getField<double>('ld_total_outstanding');
  set ldTotalOutstanding(double? value) =>
      setField<double>('ld_total_outstanding', value);

  double? get ldTotalRepayments => getField<double>('ld_total_repayments');
  set ldTotalRepayments(double? value) =>
      setField<double>('ld_total_repayments', value);

  int? get ldTotalCustomers => getField<int>('ld_total_customers');
  set ldTotalCustomers(int? value) =>
      setField<int>('ld_total_customers', value);

  int? get sysTotalLoans => getField<int>('sys_total_loans');
  set sysTotalLoans(int? value) => setField<int>('sys_total_loans', value);

  double? get sysTotalDisbursed => getField<double>('sys_total_disbursed');
  set sysTotalDisbursed(double? value) =>
      setField<double>('sys_total_disbursed', value);

  double? get sysTotalOutstanding => getField<double>('sys_total_outstanding');
  set sysTotalOutstanding(double? value) =>
      setField<double>('sys_total_outstanding', value);

  double? get sysTotalRepayments => getField<double>('sys_total_repayments');
  set sysTotalRepayments(double? value) =>
      setField<double>('sys_total_repayments', value);

  int? get sysTotalCustomers => getField<int>('sys_total_customers');
  set sysTotalCustomers(int? value) =>
      setField<int>('sys_total_customers', value);

  int? get varianceLoans => getField<int>('variance_loans');
  set varianceLoans(int? value) => setField<int>('variance_loans', value);

  double? get varianceDisbursed => getField<double>('variance_disbursed');
  set varianceDisbursed(double? value) =>
      setField<double>('variance_disbursed', value);

  double? get varianceOutstanding => getField<double>('variance_outstanding');
  set varianceOutstanding(double? value) =>
      setField<double>('variance_outstanding', value);

  double? get varianceRepayments => getField<double>('variance_repayments');
  set varianceRepayments(double? value) =>
      setField<double>('variance_repayments', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get varianceNotes => getField<String>('variance_notes');
  set varianceNotes(String? value) => setField<String>('variance_notes', value);

  String? get preparedBy => getField<String>('prepared_by');
  set preparedBy(String? value) => setField<String>('prepared_by', value);

  DateTime? get preparedAt => getField<DateTime>('prepared_at');
  set preparedAt(DateTime? value) => setField<DateTime>('prepared_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  dynamic get ldSnapshotData => getField<dynamic>('ld_snapshot_data');
  set ldSnapshotData(dynamic value) =>
      setField<dynamic>('ld_snapshot_data', value);

  dynamic get sysSnapshotData => getField<dynamic>('sys_snapshot_data');
  set sysSnapshotData(dynamic value) =>
      setField<dynamic>('sys_snapshot_data', value);

  dynamic get varianceDetails => getField<dynamic>('variance_details');
  set varianceDetails(dynamic value) =>
      setField<dynamic>('variance_details', value);
}
