import '../database.dart';

class LegalHearingReportsTable extends SupabaseTable<LegalHearingReportsRow> {
  @override
  String get tableName => 'legal_hearing_reports';

  @override
  LegalHearingReportsRow createRow(Map<String, dynamic> data) =>
      LegalHearingReportsRow(data);
}

class LegalHearingReportsRow extends SupabaseDataRow {
  LegalHearingReportsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalHearingReportsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get hearingId => getField<String>('hearing_id')!;
  set hearingId(String value) => setField<String>('hearing_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get filePath => getField<String>('file_path')!;
  set filePath(String value) => setField<String>('file_path', value);

  String? get extractedText => getField<String>('extracted_text');
  set extractedText(String? value) => setField<String>('extracted_text', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
