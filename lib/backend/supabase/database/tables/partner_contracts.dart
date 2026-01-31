import '../database.dart';

class PartnerContractsTable extends SupabaseTable<PartnerContractsRow> {
  @override
  String get tableName => 'partner_contracts';

  @override
  PartnerContractsRow createRow(Map<String, dynamic> data) =>
      PartnerContractsRow(data);
}

class PartnerContractsRow extends SupabaseDataRow {
  PartnerContractsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PartnerContractsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get partnerUserId => getField<String>('partner_user_id')!;
  set partnerUserId(String value) => setField<String>('partner_user_id', value);

  String get contractTitle => getField<String>('contract_title')!;
  set contractTitle(String value) => setField<String>('contract_title', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get startDate => getField<DateTime>('start_date');
  set startDate(DateTime? value) => setField<DateTime>('start_date', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
