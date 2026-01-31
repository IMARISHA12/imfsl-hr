import '../database.dart';

class ZArchiveApprovalLevelsTable
    extends SupabaseTable<ZArchiveApprovalLevelsRow> {
  @override
  String get tableName => 'z_archive_approval_levels';

  @override
  ZArchiveApprovalLevelsRow createRow(Map<String, dynamic> data) =>
      ZArchiveApprovalLevelsRow(data);
}

class ZArchiveApprovalLevelsRow extends SupabaseDataRow {
  ZArchiveApprovalLevelsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveApprovalLevelsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get workflowType => getField<String>('workflow_type')!;
  set workflowType(String value) => setField<String>('workflow_type', value);

  int get levelNumber => getField<int>('level_number')!;
  set levelNumber(int value) => setField<int>('level_number', value);

  String get requiredRole => getField<String>('required_role')!;
  set requiredRole(String value) => setField<String>('required_role', value);

  double? get amountThresholdMin => getField<double>('amount_threshold_min');
  set amountThresholdMin(double? value) =>
      setField<double>('amount_threshold_min', value);

  double? get amountThresholdMax => getField<double>('amount_threshold_max');
  set amountThresholdMax(double? value) =>
      setField<double>('amount_threshold_max', value);

  List<String> get requiredPermissions =>
      getListField<String>('required_permissions');
  set requiredPermissions(List<String>? value) =>
      setListField<String>('required_permissions', value);

  bool? get canDelegate => getField<bool>('can_delegate');
  set canDelegate(bool? value) => setField<bool>('can_delegate', value);

  int? get timeoutHours => getField<int>('timeout_hours');
  set timeoutHours(int? value) => setField<int>('timeout_hours', value);

  bool? get autoEscalate => getField<bool>('auto_escalate');
  set autoEscalate(bool? value) => setField<bool>('auto_escalate', value);
}
