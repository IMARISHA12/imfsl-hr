import '../database.dart';

class StaffTargetsTable extends SupabaseTable<StaffTargetsRow> {
  @override
  String get tableName => 'staff_targets';

  @override
  StaffTargetsRow createRow(Map<String, dynamic> data) => StaffTargetsRow(data);
}

class StaffTargetsRow extends SupabaseDataRow {
  StaffTargetsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffTargetsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  DateTime get month => getField<DateTime>('month')!;
  set month(DateTime value) => setField<DateTime>('month', value);

  double? get targetDisbursement => getField<double>('target_disbursement');
  set targetDisbursement(double? value) =>
      setField<double>('target_disbursement', value);

  double? get targetCollection => getField<double>('target_collection');
  set targetCollection(double? value) =>
      setField<double>('target_collection', value);

  double? get maxPar30 => getField<double>('max_par_30');
  set maxPar30(double? value) => setField<double>('max_par_30', value);

  double? get minPtpRate => getField<double>('min_ptp_rate');
  set minPtpRate(double? value) => setField<double>('min_ptp_rate', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
