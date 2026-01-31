import '../database.dart';

class AppBannersTable extends SupabaseTable<AppBannersRow> {
  @override
  String get tableName => 'app_banners';

  @override
  AppBannersRow createRow(Map<String, dynamic> data) => AppBannersRow(data);
}

class AppBannersRow extends SupabaseDataRow {
  AppBannersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AppBannersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get targetAudience => getField<String>('target_audience');
  set targetAudience(String? value) =>
      setField<String>('target_audience', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);
}
