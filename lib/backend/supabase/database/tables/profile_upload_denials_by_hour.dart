import '../database.dart';

class ProfileUploadDenialsByHourTable
    extends SupabaseTable<ProfileUploadDenialsByHourRow> {
  @override
  String get tableName => 'profile_upload_denials_by_hour';

  @override
  ProfileUploadDenialsByHourRow createRow(Map<String, dynamic> data) =>
      ProfileUploadDenialsByHourRow(data);
}

class ProfileUploadDenialsByHourRow extends SupabaseDataRow {
  ProfileUploadDenialsByHourRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfileUploadDenialsByHourTable();

  DateTime? get hour => getField<DateTime>('hour');
  set hour(DateTime? value) => setField<DateTime>('hour', value);

  int? get denialCount => getField<int>('denial_count');
  set denialCount(int? value) => setField<int>('denial_count', value);

  int? get uniqueUsers => getField<int>('unique_users');
  set uniqueUsers(int? value) => setField<int>('unique_users', value);

  int? get uniqueIps => getField<int>('unique_ips');
  set uniqueIps(int? value) => setField<int>('unique_ips', value);
}
