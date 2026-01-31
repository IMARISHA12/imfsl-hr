import '../database.dart';

class LoandiskExportRequestsTable
    extends SupabaseTable<LoandiskExportRequestsRow> {
  @override
  String get tableName => 'loandisk_export_requests';

  @override
  LoandiskExportRequestsRow createRow(Map<String, dynamic> data) =>
      LoandiskExportRequestsRow(data);
}

class LoandiskExportRequestsRow extends SupabaseDataRow {
  LoandiskExportRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoandiskExportRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get requestNumber => getField<String>('request_number')!;
  set requestNumber(String value) => setField<String>('request_number', value);

  String get exportType => getField<String>('export_type')!;
  set exportType(String value) => setField<String>('export_type', value);

  dynamic get exportScope => getField<dynamic>('export_scope')!;
  set exportScope(dynamic value) => setField<dynamic>('export_scope', value);

  String get purpose => getField<String>('purpose')!;
  set purpose(String value) => setField<String>('purpose', value);

  String get purposeDetails => getField<String>('purpose_details')!;
  set purposeDetails(String value) =>
      setField<String>('purpose_details', value);

  String? get ticketReference => getField<String>('ticket_reference');
  set ticketReference(String? value) =>
      setField<String>('ticket_reference', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get requestedBy => getField<String>('requested_by')!;
  set requestedBy(String value) => setField<String>('requested_by', value);

  DateTime get requestedAt => getField<DateTime>('requested_at')!;
  set requestedAt(DateTime value) => setField<DateTime>('requested_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get approvalNotes => getField<String>('approval_notes');
  set approvalNotes(String? value) => setField<String>('approval_notes', value);

  String? get rejectedBy => getField<String>('rejected_by');
  set rejectedBy(String? value) => setField<String>('rejected_by', value);

  DateTime? get rejectedAt => getField<DateTime>('rejected_at');
  set rejectedAt(DateTime? value) => setField<DateTime>('rejected_at', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  String? get exportedBy => getField<String>('exported_by');
  set exportedBy(String? value) => setField<String>('exported_by', value);

  DateTime? get exportedAt => getField<DateTime>('exported_at');
  set exportedAt(DateTime? value) => setField<DateTime>('exported_at', value);

  String? get exportFileName => getField<String>('export_file_name');
  set exportFileName(String? value) =>
      setField<String>('export_file_name', value);

  int? get exportFileSizeBytes => getField<int>('export_file_size_bytes');
  set exportFileSizeBytes(int? value) =>
      setField<int>('export_file_size_bytes', value);

  String? get exportFileHash => getField<String>('export_file_hash');
  set exportFileHash(String? value) =>
      setField<String>('export_file_hash', value);

  String? get exportFilePath => getField<String>('export_file_path');
  set exportFilePath(String? value) =>
      setField<String>('export_file_path', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  DateTime? get deletedAt => getField<DateTime>('deleted_at');
  set deletedAt(DateTime? value) => setField<DateTime>('deleted_at', value);

  String? get deletedBy => getField<String>('deleted_by');
  set deletedBy(String? value) => setField<String>('deleted_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
