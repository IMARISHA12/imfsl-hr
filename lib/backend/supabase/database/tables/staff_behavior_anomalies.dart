import '../database.dart';

class StaffBehaviorAnomaliesTable
    extends SupabaseTable<StaffBehaviorAnomaliesRow> {
  @override
  String get tableName => 'staff_behavior_anomalies';

  @override
  StaffBehaviorAnomaliesRow createRow(Map<String, dynamic> data) =>
      StaffBehaviorAnomaliesRow(data);
}

class StaffBehaviorAnomaliesRow extends SupabaseDataRow {
  StaffBehaviorAnomaliesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffBehaviorAnomaliesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get anomalyType => getField<String>('anomaly_type')!;
  set anomalyType(String value) => setField<String>('anomaly_type', value);

  int get riskScore => getField<int>('risk_score')!;
  set riskScore(int value) => setField<int>('risk_score', value);

  dynamic get details => getField<dynamic>('details')!;
  set details(dynamic value) => setField<dynamic>('details', value);

  DateTime get occurredAt => getField<DateTime>('occurred_at')!;
  set occurredAt(DateTime value) => setField<DateTime>('occurred_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
