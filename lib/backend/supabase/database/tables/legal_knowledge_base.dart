import '../database.dart';

class LegalKnowledgeBaseTable extends SupabaseTable<LegalKnowledgeBaseRow> {
  @override
  String get tableName => 'legal_knowledge_base';

  @override
  LegalKnowledgeBaseRow createRow(Map<String, dynamic> data) =>
      LegalKnowledgeBaseRow(data);
}

class LegalKnowledgeBaseRow extends SupabaseDataRow {
  LegalKnowledgeBaseRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LegalKnowledgeBaseTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String? get sourceUrl => getField<String>('source_url');
  set sourceUrl(String? value) => setField<String>('source_url', value);

  String? get fullText => getField<String>('full_text');
  set fullText(String? value) => setField<String>('full_text', value);

  String? get summaryPlainText => getField<String>('summary_plain_text');
  set summaryPlainText(String? value) =>
      setField<String>('summary_plain_text', value);

  DateTime? get effectiveDate => getField<DateTime>('effective_date');
  set effectiveDate(DateTime? value) =>
      setField<DateTime>('effective_date', value);

  dynamic get aiInterpretation => getField<dynamic>('ai_interpretation');
  set aiInterpretation(dynamic value) =>
      setField<dynamic>('ai_interpretation', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
