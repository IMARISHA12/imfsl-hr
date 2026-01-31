import '../database.dart';

class VLoansAuditTable extends SupabaseTable<VLoansAuditRow> {
  @override
  String get tableName => 'v_loans_audit';

  @override
  VLoansAuditRow createRow(Map<String, dynamic> data) => VLoansAuditRow(data);
}

class VLoansAuditRow extends SupabaseDataRow {
  VLoansAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VLoansAuditTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String? get branchName => getField<String>('branch_name');
  set branchName(String? value) => setField<String>('branch_name', value);

  String? get branchLocation => getField<String>('branch_location');
  set branchLocation(String? value) =>
      setField<String>('branch_location', value);

  String? get applicantName => getField<String>('applicant_name');
  set applicantName(String? value) => setField<String>('applicant_name', value);

  double? get principalAmount => getField<double>('principal_amount');
  set principalAmount(double? value) =>
      setField<double>('principal_amount', value);

  double? get balance => getField<double>('balance');
  set balance(double? value) => setField<double>('balance', value);

  double? get penaltyBalance => getField<double>('penalty_balance');
  set penaltyBalance(double? value) =>
      setField<double>('penalty_balance', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  bool? get legalFreeze => getField<bool>('legal_freeze');
  set legalFreeze(bool? value) => setField<bool>('legal_freeze', value);

  DateTime? get freezeDate => getField<DateTime>('freeze_date');
  set freezeDate(DateTime? value) => setField<DateTime>('freeze_date', value);

  DateTime? get lastPenaltyDate => getField<DateTime>('last_penalty_date');
  set lastPenaltyDate(DateTime? value) =>
      setField<DateTime>('last_penalty_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
