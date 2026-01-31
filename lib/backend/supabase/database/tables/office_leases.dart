import '../database.dart';

class OfficeLeasesTable extends SupabaseTable<OfficeLeasesRow> {
  @override
  String get tableName => 'office_leases';

  @override
  OfficeLeasesRow createRow(Map<String, dynamic> data) => OfficeLeasesRow(data);
}

class OfficeLeasesRow extends SupabaseDataRow {
  OfficeLeasesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OfficeLeasesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get branchName => getField<String>('branch_name')!;
  set branchName(String value) => setField<String>('branch_name', value);

  String get landlordName => getField<String>('landlord_name')!;
  set landlordName(String value) => setField<String>('landlord_name', value);

  String? get paymentDetails => getField<String>('payment_details');
  set paymentDetails(String? value) =>
      setField<String>('payment_details', value);

  DateTime get leaseEndDate => getField<DateTime>('lease_end_date')!;
  set leaseEndDate(DateTime value) =>
      setField<DateTime>('lease_end_date', value);

  double get amountPerPeriod => getField<double>('amount_per_period')!;
  set amountPerPeriod(double value) =>
      setField<double>('amount_per_period', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String get frequency => getField<String>('frequency')!;
  set frequency(String value) => setField<String>('frequency', value);

  DateTime get nextDueDate => getField<DateTime>('next_due_date')!;
  set nextDueDate(DateTime value) => setField<DateTime>('next_due_date', value);

  bool get isActive => getField<bool>('is_active')!;
  set isActive(bool value) => setField<bool>('is_active', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
