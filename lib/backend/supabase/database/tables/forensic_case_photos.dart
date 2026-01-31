import '../database.dart';

class ForensicCasePhotosTable extends SupabaseTable<ForensicCasePhotosRow> {
  @override
  String get tableName => 'forensic_case_photos';

  @override
  ForensicCasePhotosRow createRow(Map<String, dynamic> data) =>
      ForensicCasePhotosRow(data);
}

class ForensicCasePhotosRow extends SupabaseDataRow {
  ForensicCasePhotosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ForensicCasePhotosTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String get stage => getField<String>('stage')!;
  set stage(String value) => setField<String>('stage', value);

  String get objectPath => getField<String>('object_path')!;
  set objectPath(String value) => setField<String>('object_path', value);

  DateTime get capturedAt => getField<DateTime>('captured_at')!;
  set capturedAt(DateTime value) => setField<DateTime>('captured_at', value);

  double? get lat => getField<double>('lat');
  set lat(double? value) => setField<double>('lat', value);

  double? get lng => getField<double>('lng');
  set lng(double? value) => setField<double>('lng', value);

  double? get accuracyM => getField<double>('accuracy_m');
  set accuracyM(double? value) => setField<double>('accuracy_m', value);

  dynamic get deviceInfo => getField<dynamic>('device_info');
  set deviceInfo(dynamic value) => setField<dynamic>('device_info', value);

  String get uploadedBy => getField<String>('uploaded_by')!;
  set uploadedBy(String value) => setField<String>('uploaded_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
