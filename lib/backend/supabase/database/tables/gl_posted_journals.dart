import '../database.dart';

class GlPostedJournalsTable extends SupabaseTable<GlPostedJournalsRow> {
  @override
  String get tableName => 'gl_posted_journals';

  @override
  GlPostedJournalsRow createRow(Map<String, dynamic> data) =>
      GlPostedJournalsRow(data);
}

class GlPostedJournalsRow extends SupabaseDataRow {
  GlPostedJournalsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GlPostedJournalsTable();

  String get journalId => getField<String>('journal_id')!;
  set journalId(String value) => setField<String>('journal_id', value);

  DateTime get postedAt => getField<DateTime>('posted_at')!;
  set postedAt(DateTime value) => setField<DateTime>('posted_at', value);

  String? get postedBy => getField<String>('posted_by');
  set postedBy(String? value) => setField<String>('posted_by', value);
}
