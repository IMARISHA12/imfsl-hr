import '../database.dart';

class AssetMaintenanceRecordsTable
    extends SupabaseTable<AssetMaintenanceRecordsRow> {
  @override
  String get tableName => 'asset_maintenance_records';

  @override
  AssetMaintenanceRecordsRow createRow(Map<String, dynamic> data) =>
      AssetMaintenanceRecordsRow(data);
}

class AssetMaintenanceRecordsRow extends SupabaseDataRow {
  AssetMaintenanceRecordsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetMaintenanceRecordsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get assetId => getField<String>('asset_id')!;
  set assetId(String value) => setField<String>('asset_id', value);

  String get maintenanceType => getField<String>('maintenance_type')!;
  set maintenanceType(String value) =>
      setField<String>('maintenance_type', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  DateTime? get scheduledDate => getField<DateTime>('scheduled_date');
  set scheduledDate(DateTime? value) =>
      setField<DateTime>('scheduled_date', value);

  DateTime? get completedDate => getField<DateTime>('completed_date');
  set completedDate(DateTime? value) =>
      setField<DateTime>('completed_date', value);

  double? get cost => getField<double>('cost');
  set cost(double? value) => setField<double>('cost', value);

  String? get vendorName => getField<String>('vendor_name');
  set vendorName(String? value) => setField<String>('vendor_name', value);

  String? get technicianName => getField<String>('technician_name');
  set technicianName(String? value) =>
      setField<String>('technician_name', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get priority => getField<String>('priority');
  set priority(String? value) => setField<String>('priority', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  dynamic get attachmentUrls => getField<dynamic>('attachment_urls');
  set attachmentUrls(dynamic value) =>
      setField<dynamic>('attachment_urls', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
