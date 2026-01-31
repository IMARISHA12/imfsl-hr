import '../database.dart';

class PettyCashEnrichedTable extends SupabaseTable<PettyCashEnrichedRow> {
  @override
  String get tableName => 'petty_cash_enriched';

  @override
  PettyCashEnrichedRow createRow(Map<String, dynamic> data) =>
      PettyCashEnrichedRow(data);
}

class PettyCashEnrichedRow extends SupabaseDataRow {
  PettyCashEnrichedRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PettyCashEnrichedTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get requestedBy => getField<String>('requested_by');
  set requestedBy(String? value) => setField<String>('requested_by', value);

  double? get amount => getField<double>('amount');
  set amount(double? value) => setField<double>('amount', value);

  String? get purpose => getField<String>('purpose');
  set purpose(String? value) => setField<String>('purpose', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  int? get approvalLevel => getField<int>('approval_level');
  set approvalLevel(int? value) => setField<int>('approval_level', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get requestedByName => getField<String>('requested_by_name');
  set requestedByName(String? value) =>
      setField<String>('requested_by_name', value);

  String? get requestedByEmail => getField<String>('requested_by_email');
  set requestedByEmail(String? value) =>
      setField<String>('requested_by_email', value);
}
