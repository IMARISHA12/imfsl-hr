import '../database.dart';

class AssetAttachmentsTable extends SupabaseTable<AssetAttachmentsRow> {
  @override
  String get tableName => 'asset_attachments';

  @override
  AssetAttachmentsRow createRow(Map<String, dynamic> data) =>
      AssetAttachmentsRow(data);
}

class AssetAttachmentsRow extends SupabaseDataRow {
  AssetAttachmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssetAttachmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get entityType => getField<String>('entity_type')!;
  set entityType(String value) => setField<String>('entity_type', value);

  String get entityId => getField<String>('entity_id')!;
  set entityId(String value) => setField<String>('entity_id', value);

  String get fileName => getField<String>('file_name')!;
  set fileName(String value) => setField<String>('file_name', value);

  String get fileType => getField<String>('file_type')!;
  set fileType(String value) => setField<String>('file_type', value);

  String? get mimeType => getField<String>('mime_type');
  set mimeType(String? value) => setField<String>('mime_type', value);

  int? get fileSizeBytes => getField<int>('file_size_bytes');
  set fileSizeBytes(int? value) =>
      setField<int>('file_size_bytes', value);

  String get storagePath => getField<String>('storage_path')!;
  set storagePath(String value) =>
      setField<String>('storage_path', value);

  String get storageBucket => getField<String>('storage_bucket')!;
  set storageBucket(String value) =>
      setField<String>('storage_bucket', value);

  String? get publicUrl => getField<String>('public_url');
  set publicUrl(String? value) => setField<String>('public_url', value);

  String? get thumbnailUrl => getField<String>('thumbnail_url');
  set thumbnailUrl(String? value) =>
      setField<String>('thumbnail_url', value);

  String get captureMethod => getField<String>('capture_method')!;
  set captureMethod(String value) =>
      setField<String>('capture_method', value);

  String? get captureDevice => getField<String>('capture_device');
  set captureDevice(String? value) =>
      setField<String>('capture_device', value);

  double? get captureLocationLat =>
      getField<double>('capture_location_lat');
  set captureLocationLat(double? value) =>
      setField<double>('capture_location_lat', value);

  double? get captureLocationLng =>
      getField<double>('capture_location_lng');
  set captureLocationLng(double? value) =>
      setField<double>('capture_location_lng', value);

  String? get fileHashSha256 => getField<String>('file_hash_sha256');
  set fileHashSha256(String? value) =>
      setField<String>('file_hash_sha256', value);

  String? get perceptualHash => getField<String>('perceptual_hash');
  set perceptualHash(String? value) =>
      setField<String>('perceptual_hash', value);

  String? get ocrStatus => getField<String>('ocr_status');
  set ocrStatus(String? value) => setField<String>('ocr_status', value);

  String? get fraudCheckStatus =>
      getField<String>('fraud_check_status');
  set fraudCheckStatus(String? value) =>
      setField<String>('fraud_check_status', value);

  int get fraudRiskScore => getField<int>('fraud_risk_score') ?? 0;
  set fraudRiskScore(int value) =>
      setField<int>('fraud_risk_score', value);

  bool get isVerified => getField<bool>('is_verified') ?? false;
  set isVerified(bool value) => setField<bool>('is_verified', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) =>
      setField<String>('verified_by', value);

  String? get documentType => getField<String>('document_type');
  set documentType(String? value) =>
      setField<String>('document_type', value);

  List<String> get tags => getListField<String>('tags');
  set tags(List<String>? value) => setListField<String>('tags', value);

  String? get aiDetectedType => getField<String>('ai_detected_type');
  set aiDetectedType(String? value) =>
      setField<String>('ai_detected_type', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get uploadedBy => getField<String>('uploaded_by')!;
  set uploadedBy(String value) => setField<String>('uploaded_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) =>
      setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) =>
      setField<DateTime>('updated_at', value);
}
