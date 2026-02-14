import '../database.dart';

class FineractReconciliationSnapshotsTable
    extends SupabaseTable<FineractReconciliationSnapshotsRow> {
  @override
  String get tableName => 'fineract_reconciliation_snapshots';

  @override
  FineractReconciliationSnapshotsRow createRow(Map<String, dynamic> data) =>
      FineractReconciliationSnapshotsRow(data);
}

class FineractReconciliationSnapshotsRow extends SupabaseDataRow {
  FineractReconciliationSnapshotsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FineractReconciliationSnapshotsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get reconciliationDate =>
      getField<DateTime>('reconciliation_date')!;
  set reconciliationDate(DateTime value) =>
      setField<DateTime>('reconciliation_date', value);

  DateTime get periodStart => getField<DateTime>('period_start')!;
  set periodStart(DateTime value) => setField<DateTime>('period_start', value);

  DateTime get periodEnd => getField<DateTime>('period_end')!;
  set periodEnd(DateTime value) => setField<DateTime>('period_end', value);

  int? get fnTotalLoans => getField<int>('fn_total_loans');
  set fnTotalLoans(int? value) => setField<int>('fn_total_loans', value);

  double? get fnTotalDisbursed => getField<double>('fn_total_disbursed');
  set fnTotalDisbursed(double? value) =>
      setField<double>('fn_total_disbursed', value);

  double? get fnTotalOutstanding => getField<double>('fn_total_outstanding');
  set fnTotalOutstanding(double? value) =>
      setField<double>('fn_total_outstanding', value);

  double? get fnTotalRepayments => getField<double>('fn_total_repayments');
  set fnTotalRepayments(double? value) =>
      setField<double>('fn_total_repayments', value);

  int? get fnTotalClients => getField<int>('fn_total_clients');
  set fnTotalClients(int? value) => setField<int>('fn_total_clients', value);

  double? get fnTotalSavings => getField<double>('fn_total_savings');
  set fnTotalSavings(double? value) =>
      setField<double>('fn_total_savings', value);

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

  int? get sysTotalClients => getField<int>('sys_total_clients');
  set sysTotalClients(int? value) => setField<int>('sys_total_clients', value);

  double? get sysTotalSavings => getField<double>('sys_total_savings');
  set sysTotalSavings(double? value) =>
      setField<double>('sys_total_savings', value);

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

  double? get varianceSavings => getField<double>('variance_savings');
  set varianceSavings(double? value) =>
      setField<double>('variance_savings', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get varianceNotes => getField<String>('variance_notes');
  set varianceNotes(String? value) =>
      setField<String>('variance_notes', value);

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

  dynamic get fnSnapshotData => getField<dynamic>('fn_snapshot_data');
  set fnSnapshotData(dynamic value) =>
      setField<dynamic>('fn_snapshot_data', value);

  dynamic get sysSnapshotData => getField<dynamic>('sys_snapshot_data');
  set sysSnapshotData(dynamic value) =>
      setField<dynamic>('sys_snapshot_data', value);

  dynamic get varianceDetails => getField<dynamic>('variance_details');
  set varianceDetails(dynamic value) =>
      setField<dynamic>('variance_details', value);
}
