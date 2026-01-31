import '../database.dart';

class LegalHearingsTable extends SupabaseTable<LegalHearingsRow> {
  @override
  String get tableName => 'legal_hearings';

  @override
  LegalHearingsRow createRow(Map<String, dynamic> data) =>
      LegalHearingsRow(data);
}

class LegalHearingsRow extends SupabaseDataRow {
  LegalHearingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalHearingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  DateTime get hearingAt => getField<DateTime>('hearing_at')!;
  set hearingAt(DateTime value) => setField<DateTime>('hearing_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
