import '../database.dart';

class DocumentsTable extends SupabaseTable<DocumentsRow> {
  @override
  String get tableName => 'documents';

  @override
  DocumentsRow createRow(Map<String, dynamic> data) => DocumentsRow(data);
}

class DocumentsRow extends SupabaseDataRow {
  DocumentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DocumentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get entityType => getField<String>('entity_type')!;
  set entityType(String value) => setField<String>('entity_type', value);

  String get entityId => getField<String>('entity_id')!;
  set entityId(String value) => setField<String>('entity_id', value);

  String get docType => getField<String>('doc_type')!;
  set docType(String value) => setField<String>('doc_type', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  bool? get isSensitive => getField<bool>('is_sensitive');
  set isSensitive(bool? value) => setField<bool>('is_sensitive', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  List<String> get tags => getListField<String>('tags');
  set tags(List<String>? value) => setListField<String>('tags', value);

  String get uploadedBy => getField<String>('uploaded_by')!;
  set uploadedBy(String value) => setField<String>('uploaded_by', value);

  DateTime get uploadedAt => getField<DateTime>('uploaded_at')!;
  set uploadedAt(DateTime value) => setField<DateTime>('uploaded_at', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get ocrVerifiedBy => getField<String>('ocr_verified_by');
  set ocrVerifiedBy(String? value) =>
      setField<String>('ocr_verified_by', value);

  DateTime? get ocrVerifiedAt => getField<DateTime>('ocr_verified_at');
  set ocrVerifiedAt(DateTime? value) =>
      setField<DateTime>('ocr_verified_at', value);

  String? get ocrVerificationNotes =>
      getField<String>('ocr_verification_notes');
  set ocrVerificationNotes(String? value) =>
      setField<String>('ocr_verification_notes', value);
}
