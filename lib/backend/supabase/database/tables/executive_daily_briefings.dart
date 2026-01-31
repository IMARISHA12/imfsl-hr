import '../database.dart';

class ExecutiveDailyBriefingsTable
    extends SupabaseTable<ExecutiveDailyBriefingsRow> {
  @override
  String get tableName => 'executive_daily_briefings';

  @override
  ExecutiveDailyBriefingsRow createRow(Map<String, dynamic> data) =>
      ExecutiveDailyBriefingsRow(data);
}

class ExecutiveDailyBriefingsRow extends SupabaseDataRow {
  ExecutiveDailyBriefingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ExecutiveDailyBriefingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get briefingDate => getField<DateTime>('briefing_date')!;
  set briefingDate(DateTime value) =>
      setField<DateTime>('briefing_date', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get summaryText => getField<String>('summary_text')!;
  set summaryText(String value) => setField<String>('summary_text', value);

  dynamic get redFlags => getField<dynamic>('red_flags')!;
  set redFlags(dynamic value) => setField<dynamic>('red_flags', value);

  dynamic get metrics => getField<dynamic>('metrics')!;
  set metrics(dynamic value) => setField<dynamic>('metrics', value);

  String? get signatureSha256 => getField<String>('signature_sha256');
  set signatureSha256(String? value) =>
      setField<String>('signature_sha256', value);

  String? get generatedBy => getField<String>('generated_by');
  set generatedBy(String? value) => setField<String>('generated_by', value);

  DateTime get generatedAt => getField<DateTime>('generated_at')!;
  set generatedAt(DateTime value) => setField<DateTime>('generated_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get fileUrl => getField<String>('file_url');
  set fileUrl(String? value) => setField<String>('file_url', value);
}
