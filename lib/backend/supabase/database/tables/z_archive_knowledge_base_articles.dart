import '../database.dart';

class ZArchiveKnowledgeBaseArticlesTable
    extends SupabaseTable<ZArchiveKnowledgeBaseArticlesRow> {
  @override
  String get tableName => 'z_archive_knowledge_base_articles';

  @override
  ZArchiveKnowledgeBaseArticlesRow createRow(Map<String, dynamic> data) =>
      ZArchiveKnowledgeBaseArticlesRow(data);
}

class ZArchiveKnowledgeBaseArticlesRow extends SupabaseDataRow {
  ZArchiveKnowledgeBaseArticlesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveKnowledgeBaseArticlesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get titleSw => getField<String>('title_sw');
  set titleSw(String? value) => setField<String>('title_sw', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  String? get contentSw => getField<String>('content_sw');
  set contentSw(String? value) => setField<String>('content_sw', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get subcategory => getField<String>('subcategory');
  set subcategory(String? value) => setField<String>('subcategory', value);

  List<String> get tags => getListField<String>('tags');
  set tags(List<String>? value) => setListField<String>('tags', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int? get priority => getField<int>('priority');
  set priority(int? value) => setField<int>('priority', value);

  int? get viewCount => getField<int>('view_count');
  set viewCount(int? value) => setField<int>('view_count', value);

  int? get helpfulCount => getField<int>('helpful_count');
  set helpfulCount(int? value) => setField<int>('helpful_count', value);

  int? get notHelpfulCount => getField<int>('not_helpful_count');
  set notHelpfulCount(int? value) => setField<int>('not_helpful_count', value);

  String? get authorId => getField<String>('author_id');
  set authorId(String? value) => setField<String>('author_id', value);

  DateTime? get publishedAt => getField<DateTime>('published_at');
  set publishedAt(DateTime? value) => setField<DateTime>('published_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get searchVector => getField<String>('search_vector');
  set searchVector(String? value) => setField<String>('search_vector', value);
}
