import '../database.dart';

class AssetTransfersTable extends SupabaseTable<AssetTransfersRow> {
  @override
  String get tableName => 'asset_transfers';

  @override
  AssetTransfersRow createRow(Map<String, dynamic> data) =>
      AssetTransfersRow(data);
}

class AssetTransfersRow extends SupabaseDataRow {
  AssetTransfersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetTransfersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get assetId => getField<String>('asset_id')!;
  set assetId(String value) => setField<String>('asset_id', value);

  String? get fromBranchId => getField<String>('from_branch_id');
  set fromBranchId(String? value) =>
      setField<String>('from_branch_id', value);

  String? get toBranchId => getField<String>('to_branch_id');
  set toBranchId(String? value) => setField<String>('to_branch_id', value);

  String? get fromDepartment => getField<String>('from_department');
  set fromDepartment(String? value) =>
      setField<String>('from_department', value);

  String? get toDepartment => getField<String>('to_department');
  set toDepartment(String? value) => setField<String>('to_department', value);

  DateTime get transferDate => getField<DateTime>('transfer_date')!;
  set transferDate(DateTime value) =>
      setField<DateTime>('transfer_date', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  String get authorizedBy => getField<String>('authorized_by')!;
  set authorizedBy(String value) => setField<String>('authorized_by', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
