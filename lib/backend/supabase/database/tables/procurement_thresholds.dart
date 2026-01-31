import '../database.dart';

class ProcurementThresholdsTable
    extends SupabaseTable<ProcurementThresholdsRow> {
  @override
  String get tableName => 'procurement_thresholds';

  @override
  ProcurementThresholdsRow createRow(Map<String, dynamic> data) =>
      ProcurementThresholdsRow(data);
}

class ProcurementThresholdsRow extends SupabaseDataRow {
  ProcurementThresholdsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProcurementThresholdsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get thresholdName => getField<String>('threshold_name')!;
  set thresholdName(String value) => setField<String>('threshold_name', value);

  double get minAmount => getField<double>('min_amount')!;
  set minAmount(double value) => setField<double>('min_amount', value);

  double? get maxAmount => getField<double>('max_amount');
  set maxAmount(double? value) => setField<double>('max_amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  List<String> get requiredApprovers =>
      getListField<String>('required_approvers');
  set requiredApprovers(List<String> value) =>
      setListField<String>('required_approvers', value);

  bool? get approvalSequence => getField<bool>('approval_sequence');
  set approvalSequence(bool? value) =>
      setField<bool>('approval_sequence', value);

  int? get requiresQuotes => getField<int>('requires_quotes');
  set requiresQuotes(int? value) => setField<int>('requires_quotes', value);

  bool? get requiresTender => getField<bool>('requires_tender');
  set requiresTender(bool? value) => setField<bool>('requires_tender', value);

  bool? get requiresBoardApproval => getField<bool>('requires_board_approval');
  set requiresBoardApproval(bool? value) =>
      setField<bool>('requires_board_approval', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime get effectiveFrom => getField<DateTime>('effective_from')!;
  set effectiveFrom(DateTime value) =>
      setField<DateTime>('effective_from', value);

  DateTime? get effectiveTo => getField<DateTime>('effective_to');
  set effectiveTo(DateTime? value) => setField<DateTime>('effective_to', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
