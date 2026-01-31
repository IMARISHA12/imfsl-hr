import '../database.dart';

class AlertBaselinesTable extends SupabaseTable<AlertBaselinesRow> {
  @override
  String get tableName => 'alert_baselines';

  @override
  AlertBaselinesRow createRow(Map<String, dynamic> data) =>
      AlertBaselinesRow(data);
}

class AlertBaselinesRow extends SupabaseDataRow {
  AlertBaselinesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlertBaselinesTable();

  String? get service => getField<String>('service');
  set service(String? value) => setField<String>('service', value);

  String? get vendorId => getField<String>('vendor_id');
  set vendorId(String? value) => setField<String>('vendor_id', value);

  double? get p95SentGlobal => getField<double>('p95_sent_global');
  set p95SentGlobal(double? value) =>
      setField<double>('p95_sent_global', value);

  double? get p95SuppressedGlobal => getField<double>('p95_suppressed_global');
  set p95SuppressedGlobal(double? value) =>
      setField<double>('p95_suppressed_global', value);

  double? get partitionP95Sent => getField<double>('partition_p95_sent');
  set partitionP95Sent(double? value) =>
      setField<double>('partition_p95_sent', value);

  double? get partitionP95Suppressed =>
      getField<double>('partition_p95_suppressed');
  set partitionP95Suppressed(double? value) =>
      setField<double>('partition_p95_suppressed', value);

  double? get effectiveP95Sent => getField<double>('effective_p95_sent');
  set effectiveP95Sent(double? value) =>
      setField<double>('effective_p95_sent', value);

  double? get effectiveP95Suppressed =>
      getField<double>('effective_p95_suppressed');
  set effectiveP95Suppressed(double? value) =>
      setField<double>('effective_p95_suppressed', value);

  int? get sampleCount => getField<int>('sample_count');
  set sampleCount(int? value) => setField<int>('sample_count', value);

  String? get baselineSource => getField<String>('baseline_source');
  set baselineSource(String? value) =>
      setField<String>('baseline_source', value);
}
