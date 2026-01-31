import '../database.dart';

class ThreeWayMatchesTable extends SupabaseTable<ThreeWayMatchesRow> {
  @override
  String get tableName => 'three_way_matches';

  @override
  ThreeWayMatchesRow createRow(Map<String, dynamic> data) =>
      ThreeWayMatchesRow(data);
}

class ThreeWayMatchesRow extends SupabaseDataRow {
  ThreeWayMatchesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ThreeWayMatchesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get purchaseOrderId => getField<String>('purchase_order_id');
  set purchaseOrderId(String? value) =>
      setField<String>('purchase_order_id', value);

  String? get goodsReceivedId => getField<String>('goods_received_id');
  set goodsReceivedId(String? value) =>
      setField<String>('goods_received_id', value);

  String? get invoiceId => getField<String>('invoice_id');
  set invoiceId(String? value) => setField<String>('invoice_id', value);

  double? get poAmount => getField<double>('po_amount');
  set poAmount(double? value) => setField<double>('po_amount', value);

  double? get grnAmount => getField<double>('grn_amount');
  set grnAmount(double? value) => setField<double>('grn_amount', value);

  double? get invoiceAmount => getField<double>('invoice_amount');
  set invoiceAmount(double? value) => setField<double>('invoice_amount', value);

  double? get poQuantity => getField<double>('po_quantity');
  set poQuantity(double? value) => setField<double>('po_quantity', value);

  double? get grnQuantity => getField<double>('grn_quantity');
  set grnQuantity(double? value) => setField<double>('grn_quantity', value);

  double? get invoiceQuantity => getField<double>('invoice_quantity');
  set invoiceQuantity(double? value) =>
      setField<double>('invoice_quantity', value);

  double? get priceVariance => getField<double>('price_variance');
  set priceVariance(double? value) => setField<double>('price_variance', value);

  double? get quantityVariance => getField<double>('quantity_variance');
  set quantityVariance(double? value) =>
      setField<double>('quantity_variance', value);

  double? get variancePercentage => getField<double>('variance_percentage');
  set variancePercentage(double? value) =>
      setField<double>('variance_percentage', value);

  String? get matchStatus => getField<String>('match_status');
  set matchStatus(String? value) => setField<String>('match_status', value);

  String? get exceptionType => getField<String>('exception_type');
  set exceptionType(String? value) => setField<String>('exception_type', value);

  String? get exceptionNotes => getField<String>('exception_notes');
  set exceptionNotes(String? value) =>
      setField<String>('exception_notes', value);

  String? get resolutionAction => getField<String>('resolution_action');
  set resolutionAction(String? value) =>
      setField<String>('resolution_action', value);

  String? get resolvedBy => getField<String>('resolved_by');
  set resolvedBy(String? value) => setField<String>('resolved_by', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);

  bool? get withinTolerance => getField<bool>('within_tolerance');
  set withinTolerance(bool? value) => setField<bool>('within_tolerance', value);

  double? get toleranceAmount => getField<double>('tolerance_amount');
  set toleranceAmount(double? value) =>
      setField<double>('tolerance_amount', value);

  double? get tolerancePercentage => getField<double>('tolerance_percentage');
  set tolerancePercentage(double? value) =>
      setField<double>('tolerance_percentage', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
