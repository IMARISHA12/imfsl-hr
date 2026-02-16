import '../database.dart';

class AssetTransferHistoryTable
    extends SupabaseTable<AssetTransferHistoryRow> {
  @override
  String get tableName => 'asset_transfer_history';

  @override
  AssetTransferHistoryRow createRow(Map<String, dynamic> data) =>
      AssetTransferHistoryRow(data);
}

class AssetTransferHistoryRow extends SupabaseDataRow {
  AssetTransferHistoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetTransferHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get assetId => getField<String>('asset_id')!;
  set assetId(String value) => setField<String>('asset_id', value);

  String get transferType => getField<String>('transfer_type')!;
  set transferType(String value) =>
      setField<String>('transfer_type', value);

  String? get fromEmployeeId => getField<String>('from_employee_id');
  set fromEmployeeId(String? value) =>
      setField<String>('from_employee_id', value);

  String? get toEmployeeId => getField<String>('to_employee_id');
  set toEmployeeId(String? value) =>
      setField<String>('to_employee_id', value);

  String? get fromBranchId => getField<String>('from_branch_id');
  set fromBranchId(String? value) =>
      setField<String>('from_branch_id', value);

  String? get toBranchId => getField<String>('to_branch_id');
  set toBranchId(String? value) =>
      setField<String>('to_branch_id', value);

  DateTime get transferDate => getField<DateTime>('transfer_date')!;
  set transferDate(DateTime value) =>
      setField<DateTime>('transfer_date', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  String? get conditionAtTransfer =>
      getField<String>('condition_at_transfer');
  set conditionAtTransfer(String? value) =>
      setField<String>('condition_at_transfer', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) =>
      setField<DateTime>('created_at', value);
}
