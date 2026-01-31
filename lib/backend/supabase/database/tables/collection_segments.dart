import '../database.dart';

class CollectionSegmentsTable extends SupabaseTable<CollectionSegmentsRow> {
  @override
  String get tableName => 'collection_segments';

  @override
  CollectionSegmentsRow createRow(Map<String, dynamic> data) =>
      CollectionSegmentsRow(data);
}

class CollectionSegmentsRow extends SupabaseDataRow {
  CollectionSegmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionSegmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get segmentKey => getField<String>('segment_key')!;
  set segmentKey(String value) => setField<String>('segment_key', value);

  String get segmentName => getField<String>('segment_name')!;
  set segmentName(String value) => setField<String>('segment_name', value);

  String? get segmentNameSw => getField<String>('segment_name_sw');
  set segmentNameSw(String? value) =>
      setField<String>('segment_name_sw', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  int get dpdMin => getField<int>('dpd_min')!;
  set dpdMin(int value) => setField<int>('dpd_min', value);

  int? get dpdMax => getField<int>('dpd_max');
  set dpdMax(int? value) => setField<int>('dpd_max', value);

  double? get amountMin => getField<double>('amount_min');
  set amountMin(double? value) => setField<double>('amount_min', value);

  double? get amountMax => getField<double>('amount_max');
  set amountMax(double? value) => setField<double>('amount_max', value);

  List<String> get riskLevels => getListField<String>('risk_levels');
  set riskLevels(List<String>? value) =>
      setListField<String>('risk_levels', value);

  List<int> get cadenceDays => getListField<int>('cadence_days');
  set cadenceDays(List<int> value) => setListField<int>('cadence_days', value);

  int get priority => getField<int>('priority')!;
  set priority(int value) => setField<int>('priority', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  List<String> get preferredChannels =>
      getListField<String>('preferred_channels');
  set preferredChannels(List<String>? value) =>
      setListField<String>('preferred_channels', value);

  List<String> get behaviorBands => getListField<String>('behavior_bands');
  set behaviorBands(List<String>? value) =>
      setListField<String>('behavior_bands', value);

  List<String> get contactTimes => getListField<String>('contact_times');
  set contactTimes(List<String>? value) =>
      setListField<String>('contact_times', value);

  bool? get autoMessageEnabled => getField<bool>('auto_message_enabled');
  set autoMessageEnabled(bool? value) =>
      setField<bool>('auto_message_enabled', value);

  bool? get autoEscalateEnabled => getField<bool>('auto_escalate_enabled');
  set autoEscalateEnabled(bool? value) =>
      setField<bool>('auto_escalate_enabled', value);

  int? get maxContactAttemptsPerDay =>
      getField<int>('max_contact_attempts_per_day');
  set maxContactAttemptsPerDay(int? value) =>
      setField<int>('max_contact_attempts_per_day', value);

  int? get escalationAfterDays => getField<int>('escalation_after_days');
  set escalationAfterDays(int? value) =>
      setField<int>('escalation_after_days', value);

  String? get tonePolicy => getField<String>('tone_policy');
  set tonePolicy(String? value) => setField<String>('tone_policy', value);
}
