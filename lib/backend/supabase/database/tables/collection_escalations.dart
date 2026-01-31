import '../database.dart';

class CollectionEscalationsTable
    extends SupabaseTable<CollectionEscalationsRow> {
  @override
  String get tableName => 'collection_escalations';

  @override
  CollectionEscalationsRow createRow(Map<String, dynamic> data) =>
      CollectionEscalationsRow(data);
}

class CollectionEscalationsRow extends SupabaseDataRow {
  CollectionEscalationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CollectionEscalationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get caseId => getField<String>('case_id')!;
  set caseId(String value) => setField<String>('case_id', value);

  String get fromLevel => getField<String>('from_level')!;
  set fromLevel(String value) => setField<String>('from_level', value);

  String get toLevel => getField<String>('to_level')!;
  set toLevel(String value) => setField<String>('to_level', value);

  String get reason => getField<String>('reason')!;
  set reason(String value) => setField<String>('reason', value);

  String get escalatedBy => getField<String>('escalated_by')!;
  set escalatedBy(String value) => setField<String>('escalated_by', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
