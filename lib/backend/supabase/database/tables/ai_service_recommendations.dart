import '../database.dart';

class AiServiceRecommendationsTable
    extends SupabaseTable<AiServiceRecommendationsRow> {
  @override
  String get tableName => 'ai_service_recommendations';

  @override
  AiServiceRecommendationsRow createRow(Map<String, dynamic> data) =>
      AiServiceRecommendationsRow(data);
}

class AiServiceRecommendationsRow extends SupabaseDataRow {
  AiServiceRecommendationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AiServiceRecommendationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get recommendationType => getField<String>('recommendation_type')!;
  set recommendationType(String value) =>
      setField<String>('recommendation_type', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get priority => getField<String>('priority');
  set priority(String? value) => setField<String>('priority', value);

  String? get targetRole => getField<String>('target_role');
  set targetRole(String? value) => setField<String>('target_role', value);

  String? get actionUrl => getField<String>('action_url');
  set actionUrl(String? value) => setField<String>('action_url', value);

  bool? get isDismissed => getField<bool>('is_dismissed');
  set isDismissed(bool? value) => setField<bool>('is_dismissed', value);

  String? get dismissedBy => getField<String>('dismissed_by');
  set dismissedBy(String? value) => setField<String>('dismissed_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);
}
