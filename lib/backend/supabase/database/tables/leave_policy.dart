import '../database.dart';

class LeavePolicyTable extends SupabaseTable<LeavePolicyRow> {
  @override
  String get tableName => 'leave_policy';

  @override
  LeavePolicyRow createRow(Map<String, dynamic> data) => LeavePolicyRow(data);
}

class LeavePolicyRow extends SupabaseDataRow {
  LeavePolicyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LeavePolicyTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get leaveType => getField<String>('leave_type')!;
  set leaveType(String value) => setField<String>('leave_type', value);

  String get displayNameSw => getField<String>('display_name_sw')!;
  set displayNameSw(String value) => setField<String>('display_name_sw', value);

  int get maxDaysPerYear => getField<int>('max_days_per_year')!;
  set maxDaysPerYear(int value) => setField<int>('max_days_per_year', value);

  int? get minDaysPerRequest => getField<int>('min_days_per_request');
  set minDaysPerRequest(int? value) =>
      setField<int>('min_days_per_request', value);

  int? get maxDaysPerRequest => getField<int>('max_days_per_request');
  set maxDaysPerRequest(int? value) =>
      setField<int>('max_days_per_request', value);

  bool? get requiresAttachment => getField<bool>('requires_attachment');
  set requiresAttachment(bool? value) =>
      setField<bool>('requires_attachment', value);

  int? get requiresAdvanceNoticeDays =>
      getField<int>('requires_advance_notice_days');
  set requiresAdvanceNoticeDays(int? value) =>
      setField<int>('requires_advance_notice_days', value);

  bool? get availableToAll => getField<bool>('available_to_all');
  set availableToAll(bool? value) => setField<bool>('available_to_all', value);

  String? get genderRestriction => getField<String>('gender_restriction');
  set genderRestriction(String? value) =>
      setField<String>('gender_restriction', value);

  int? get minServiceMonths => getField<int>('min_service_months');
  set minServiceMonths(int? value) =>
      setField<int>('min_service_months', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
