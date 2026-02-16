import '../database.dart';

class AssetMaintenanceTable extends SupabaseTable<AssetMaintenanceRow> {
  @override
  String get tableName => 'asset_maintenance';

  @override
  AssetMaintenanceRow createRow(Map<String, dynamic> data) =>
      AssetMaintenanceRow(data);
}

class AssetMaintenanceRow extends SupabaseDataRow {
  AssetMaintenanceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetMaintenanceTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get assetId => getField<String>('asset_id')!;
  set assetId(String value) => setField<String>('asset_id', value);

  String get maintenanceType => getField<String>('maintenance_type')!;
  set maintenanceType(String value) =>
      setField<String>('maintenance_type', value);

  String get priority => getField<String>('priority')!;
  set priority(String value) => setField<String>('priority', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) =>
      setField<String>('description', value);

  DateTime? get scheduledDate => getField<DateTime>('scheduled_date');
  set scheduledDate(DateTime? value) =>
      setField<DateTime>('scheduled_date', value);

  DateTime? get dueDate => getField<DateTime>('due_date');
  set dueDate(DateTime? value) => setField<DateTime>('due_date', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) =>
      setField<DateTime>('completed_at', value);

  double? get estimatedCost => getField<double>('estimated_cost');
  set estimatedCost(double? value) =>
      setField<double>('estimated_cost', value);

  double? get actualCost => getField<double>('actual_cost');
  set actualCost(double? value) =>
      setField<double>('actual_cost', value);

  String? get vendorName => getField<String>('vendor_name');
  set vendorName(String? value) =>
      setField<String>('vendor_name', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get workNotes => getField<String>('work_notes');
  set workNotes(String? value) => setField<String>('work_notes', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) =>
      setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) =>
      setField<DateTime>('updated_at', value);
}
