import '../database.dart';

class FieldVisitsTable extends SupabaseTable<FieldVisitsRow> {
  @override
  String get tableName => 'field_visits';

  @override
  FieldVisitsRow createRow(Map<String, dynamic> data) => FieldVisitsRow(data);
}

class FieldVisitsRow extends SupabaseDataRow {
  FieldVisitsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FieldVisitsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get officerId => getField<String>('officer_id')!;
  set officerId(String value) => setField<String>('officer_id', value);

  String? get clientId => getField<String>('client_id');
  set clientId(String? value) => setField<String>('client_id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String get visitType => getField<String>('visit_type')!;
  set visitType(String value) => setField<String>('visit_type', value);

  double get latitude => getField<double>('latitude')!;
  set latitude(double value) => setField<double>('latitude', value);

  double get longitude => getField<double>('longitude')!;
  set longitude(double value) => setField<double>('longitude', value);

  double? get locationAccuracy => getField<double>('location_accuracy');
  set locationAccuracy(double? value) =>
      setField<double>('location_accuracy', value);

  String? get address => getField<String>('address');
  set address(String? value) => setField<String>('address', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get startedAt => getField<DateTime>('started_at')!;
  set startedAt(DateTime value) => setField<DateTime>('started_at', value);

  DateTime? get endedAt => getField<DateTime>('ended_at');
  set endedAt(DateTime? value) => setField<DateTime>('ended_at', value);

  int? get durationMinutes => getField<int>('duration_minutes');
  set durationMinutes(int? value) => setField<int>('duration_minutes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get verificationStatus => getField<String>('verification_status');
  set verificationStatus(String? value) =>
      setField<String>('verification_status', value);

  String? get verificationMethod => getField<String>('verification_method');
  set verificationMethod(String? value) =>
      setField<String>('verification_method', value);

  double? get clientDistanceMeters =>
      getField<double>('client_distance_meters');
  set clientDistanceMeters(double? value) =>
      setField<double>('client_distance_meters', value);

  String? get photoEvidenceUrl => getField<String>('photo_evidence_url');
  set photoEvidenceUrl(String? value) =>
      setField<String>('photo_evidence_url', value);

  String? get verificationNotes => getField<String>('verification_notes');
  set verificationNotes(String? value) =>
      setField<String>('verification_notes', value);

  DateTime? get verifiedAt => getField<DateTime>('verified_at');
  set verifiedAt(DateTime? value) => setField<DateTime>('verified_at', value);

  String? get verifiedBy => getField<String>('verified_by');
  set verifiedBy(String? value) => setField<String>('verified_by', value);
}
