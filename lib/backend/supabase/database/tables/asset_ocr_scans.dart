import '../database.dart';

class AssetOcrScansTable extends SupabaseTable<AssetOcrScansRow> {
  @override
  String get tableName => 'asset_ocr_scans';

  @override
  AssetOcrScansRow createRow(Map<String, dynamic> data) =>
      AssetOcrScansRow(data);
}

class AssetOcrScansRow extends SupabaseDataRow {
  AssetOcrScansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetOcrScansTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get assetId => getField<String>('asset_id');
  set assetId(String? value) => setField<String>('asset_id', value);

  String? get maintenanceId => getField<String>('maintenance_id');
  set maintenanceId(String? value) =>
      setField<String>('maintenance_id', value);

  String get scanType => getField<String>('scan_type')!;
  set scanType(String value) => setField<String>('scan_type', value);

  String? get originalFilename => getField<String>('original_filename');
  set originalFilename(String? value) =>
      setField<String>('original_filename', value);

  String get storagePath => getField<String>('storage_path')!;
  set storagePath(String value) => setField<String>('storage_path', value);

  int? get fileSizeBytes => getField<int>('file_size_bytes');
  set fileSizeBytes(int? value) => setField<int>('file_size_bytes', value);

  String? get mimeType => getField<String>('mime_type');
  set mimeType(String? value) => setField<String>('mime_type', value);

  String? get imageHash => getField<String>('image_hash');
  set imageHash(String? value) => setField<String>('image_hash', value);

  String? get ocrEngine => getField<String>('ocr_engine');
  set ocrEngine(String? value) => setField<String>('ocr_engine', value);

  String get ocrStatus => getField<String>('ocr_status')!;
  set ocrStatus(String value) => setField<String>('ocr_status', value);

  String? get extractedText => getField<String>('extracted_text');
  set extractedText(String? value) =>
      setField<String>('extracted_text', value);

  dynamic get extractedFields => getField<dynamic>('extracted_fields');
  set extractedFields(dynamic value) =>
      setField<dynamic>('extracted_fields', value);

  double? get confidenceScore => getField<double>('confidence_score');
  set confidenceScore(double? value) =>
      setField<double>('confidence_score', value);

  String? get detectedLanguage => getField<String>('detected_language');
  set detectedLanguage(String? value) =>
      setField<String>('detected_language', value);

  bool? get isLiveCapture => getField<bool>('is_live_capture');
  set isLiveCapture(bool? value) => setField<bool>('is_live_capture', value);

  double? get captureLatitude => getField<double>('capture_latitude');
  set captureLatitude(double? value) =>
      setField<double>('capture_latitude', value);

  double? get captureLongitude => getField<double>('capture_longitude');
  set captureLongitude(double? value) =>
      setField<double>('capture_longitude', value);

  DateTime? get captureTimestamp => getField<DateTime>('capture_timestamp');
  set captureTimestamp(DateTime? value) =>
      setField<DateTime>('capture_timestamp', value);

  dynamic get deviceInfo => getField<dynamic>('device_info');
  set deviceInfo(dynamic value) => setField<dynamic>('device_info', value);

  String? get fraudAnalysisStatus =>
      getField<String>('fraud_analysis_status');
  set fraudAnalysisStatus(String? value) =>
      setField<String>('fraud_analysis_status', value);

  int? get fraudRiskScore => getField<int>('fraud_risk_score');
  set fraudRiskScore(int? value) => setField<int>('fraud_risk_score', value);

  dynamic get fraudIndicators => getField<dynamic>('fraud_indicators');
  set fraudIndicators(dynamic value) =>
      setField<dynamic>('fraud_indicators', value);

  dynamic get fraudAnalysisDetails =>
      getField<dynamic>('fraud_analysis_details');
  set fraudAnalysisDetails(dynamic value) =>
      setField<dynamic>('fraud_analysis_details', value);

  bool? get isDuplicate => getField<bool>('is_duplicate');
  set isDuplicate(bool? value) => setField<bool>('is_duplicate', value);

  bool? get metadataTamperingDetected =>
      getField<bool>('metadata_tampering_detected');
  set metadataTamperingDetected(bool? value) =>
      setField<bool>('metadata_tampering_detected', value);

  bool? get imageManipulationDetected =>
      getField<bool>('image_manipulation_detected');
  set imageManipulationDetected(bool? value) =>
      setField<bool>('image_manipulation_detected', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  String get uploadedBy => getField<String>('uploaded_by')!;
  set uploadedBy(String value) => setField<String>('uploaded_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
