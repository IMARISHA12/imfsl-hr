import '/flutter_flow/flutter_flow_util.dart';
import 'mali_ya_kampuni_widget.dart' show MaliYaKampuniWidget;
import 'package:flutter/material.dart';

class MaliYaKampuniModel extends FlutterFlowModel<MaliYaKampuniWidget> {
  // ── KPI Data ──
  int totalAssets = 0;
  double totalAssetValue = 0;
  double totalDepreciation = 0;
  int maintenanceDue = 0;
  int fraudAlerts = 0;
  int quarantinedDocs = 0;

  // ── Lists ──
  List<Map<String, dynamic>> assets = [];
  List<Map<String, dynamic>> categoryStats = [];
  List<Map<String, dynamic>> maintenanceList = [];
  List<Map<String, dynamic>> fraudAlertsList = [];
  List<Map<String, dynamic>> systemAlerts = [];
  List<Map<String, dynamic>> techHealth = [];
  List<Map<String, dynamic>> recentAttachments = [];
  List<Map<String, dynamic>> expiringInsurance = [];

  // ── State ──
  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'all';
  String selectedTab = 'assets';  // assets, ocr, fraud, tech, alerts

  // ── Attachment Upload ──
  bool isUploading = false;
  bool isProcessingOcr = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
