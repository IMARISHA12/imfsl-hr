import '../database.dart';

class ForensicRecoveryCasesTable
    extends SupabaseTable<ForensicRecoveryCasesRow> {
  @override
  String get tableName => 'forensic_recovery_cases';

  @override
  ForensicRecoveryCasesRow createRow(Map<String, dynamic> data) =>
      ForensicRecoveryCasesRow(data);
}

class ForensicRecoveryCasesRow extends SupabaseDataRow {
  ForensicRecoveryCasesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ForensicRecoveryCasesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get loanId => getField<String>('loan_id');
  set loanId(String? value) => setField<String>('loan_id', value);

  String? get seizedAssetId => getField<String>('seized_asset_id');
  set seizedAssetId(String? value) =>
      setField<String>('seized_asset_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get zone => getField<String>('zone');
  set zone(String? value) => setField<String>('zone', value);

  String? get assignedAuctioneerId =>
      getField<String>('assigned_auctioneer_id');
  set assignedAuctioneerId(String? value) =>
      setField<String>('assigned_auctioneer_id', value);

  DateTime? get acceptedAt => getField<DateTime>('accepted_at');
  set acceptedAt(DateTime? value) => setField<DateTime>('accepted_at', value);

  String? get yardGuardId => getField<String>('yard_guard_id');
  set yardGuardId(String? value) => setField<String>('yard_guard_id', value);

  DateTime? get arrivedYardAt => getField<DateTime>('arrived_yard_at');
  set arrivedYardAt(DateTime? value) =>
      setField<DateTime>('arrived_yard_at', value);

  bool get seizureRequired => getField<bool>('seizure_required')!;
  set seizureRequired(bool value) => setField<bool>('seizure_required', value);

  bool get yardPhotosRequired => getField<bool>('yard_photos_required')!;
  set yardPhotosRequired(bool value) =>
      setField<bool>('yard_photos_required', value);

  String get liabilityFlag => getField<String>('liability_flag')!;
  set liabilityFlag(String value) => setField<String>('liability_flag', value);

  String? get liabilityReason => getField<String>('liability_reason');
  set liabilityReason(String? value) =>
      setField<String>('liability_reason', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get customerId => getField<String>('customer_id');
  set customerId(String? value) => setField<String>('customer_id', value);
}
