import '../database.dart';

class ClientRequestsTable extends SupabaseTable<ClientRequestsRow> {
  @override
  String get tableName => 'client_requests';

  @override
  ClientRequestsRow createRow(Map<String, dynamic> data) =>
      ClientRequestsRow(data);
}

class ClientRequestsRow extends SupabaseDataRow {
  ClientRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ClientRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get clientId => getField<String>('client_id')!;
  set clientId(String value) => setField<String>('client_id', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
