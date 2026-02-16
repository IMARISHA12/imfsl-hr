import '../database.dart';

class TechMonitoringSnapshotsTable
    extends SupabaseTable<TechMonitoringSnapshotsRow> {
  @override
  String get tableName => 'tech_monitoring_snapshots';

  @override
  TechMonitoringSnapshotsRow createRow(Map<String, dynamic> data) =>
      TechMonitoringSnapshotsRow(data);
}

class TechMonitoringSnapshotsRow extends SupabaseDataRow {
  TechMonitoringSnapshotsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TechMonitoringSnapshotsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get snapshotType => getField<String>('snapshot_type')!;
  set snapshotType(String value) => setField<String>('snapshot_type', value);

  String get componentName => getField<String>('component_name')!;
  set componentName(String value) =>
      setField<String>('component_name', value);

  String get healthStatus => getField<String>('health_status')!;
  set healthStatus(String value) => setField<String>('health_status', value);

  double? get uptimePercentage => getField<double>('uptime_percentage');
  set uptimePercentage(double? value) =>
      setField<double>('uptime_percentage', value);

  int? get responseTimeMs => getField<int>('response_time_ms');
  set responseTimeMs(int? value) => setField<int>('response_time_ms', value);

  double? get cpuUsagePercent => getField<double>('cpu_usage_percent');
  set cpuUsagePercent(double? value) =>
      setField<double>('cpu_usage_percent', value);

  double? get memoryUsagePercent => getField<double>('memory_usage_percent');
  set memoryUsagePercent(double? value) =>
      setField<double>('memory_usage_percent', value);

  double? get diskUsagePercent => getField<double>('disk_usage_percent');
  set diskUsagePercent(double? value) =>
      setField<double>('disk_usage_percent', value);

  int? get activeConnections => getField<int>('active_connections');
  set activeConnections(int? value) =>
      setField<int>('active_connections', value);

  double? get errorRatePercent => getField<double>('error_rate_percent');
  set errorRatePercent(double? value) =>
      setField<double>('error_rate_percent', value);

  dynamic get metricsJson => getField<dynamic>('metrics_json');
  set metricsJson(dynamic value) => setField<dynamic>('metrics_json', value);

  int? get alertCount => getField<int>('alert_count');
  set alertCount(int? value) => setField<int>('alert_count', value);

  DateTime? get lastIncidentAt => getField<DateTime>('last_incident_at');
  set lastIncidentAt(DateTime? value) =>
      setField<DateTime>('last_incident_at', value);

  DateTime? get checkedAt => getField<DateTime>('checked_at');
  set checkedAt(DateTime? value) => setField<DateTime>('checked_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
