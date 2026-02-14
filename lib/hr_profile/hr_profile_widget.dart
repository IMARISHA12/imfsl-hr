import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/backend/supabase/hr_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hr_profile_model.dart';
export 'hr_profile_model.dart';

/// Employee Profile — Personal details, employment info, contract status.
///
/// HEADER: Avatar circle, name, code, department
/// SECTIONS: Personal Info, Employment Info, Contract, Bank Details
/// ACTION: Sign Out button
class HrProfileWidget extends StatefulWidget {
  const HrProfileWidget({super.key});

  static String routeName = 'HrProfile';
  static String routePath = '/hrProfile';

  @override
  State<HrProfileWidget> createState() => _HrProfileWidgetState();
}

class _HrProfileWidgetState extends State<HrProfileWidget> {
  late HrProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrProfileModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    try {
      final empRows = await EmployeesTable().queryRows(
        queryFn: (q) => q.eqOrNull('user_id', currentUserUid).limit(1),
      );
      if (empRows.isNotEmpty) {
        _model.employee = empRows.first.data;
        final salary =
            await HrService.instance.getMySalary(empRows.first.id);
        _model.salary = salary;
      }
      _model.isLoading = false;
    } catch (e) {
      _model.isLoading = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hitilafu kupakia wasifu: $e')),
        );
      }
    }
    safeSetState(() {});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          title: Text(
            'Wasifu Wangu',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
        ),
        body: _model.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : _model.employee == null
                ? Center(
                    child: Text(
                      'Rekodi ya mfanyakazi haijapatikana',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildProfileHeader(context),
                        const SizedBox(height: 20.0),
                        _buildSection(context, 'Taarifa Binafsi', [
                          _infoRow('Jina Kamili', _e('full_name')),
                          _infoRow('Barua Pepe', _e('email')),
                          _infoRow('Simu', _e('phone_number')),
                          _infoRow('Jinsia', _e('gender')),
                          _infoRow('Tarehe ya Kuzaliwa', _e('date_of_birth')),
                          _infoRow('NIDA/Kitambulisho', _e('national_id')),
                        ]),
                        const SizedBox(height: 14.0),
                        _buildSection(context, 'Taarifa za Kazi', [
                          _infoRow('Namba ya Mfanyakazi', _e('employee_code')),
                          _infoRow('Idara', _e('dept')),
                          _infoRow('Cheo', _e('position')),
                          _infoRow('Tawi', _e('branch')),
                          _infoRow('Aina ya Ajira', _e('employment_type')),
                          _infoRow('Hali', _e('employment_status') ?? _e('status')),
                          _infoRow('Tarehe ya Kuajiriwa', _e('hire_date')),
                        ]),
                        const SizedBox(height: 14.0),
                        _buildSection(context, 'Mkataba', [
                          _infoRow('Mwanzo', _e('contract_start_date')),
                          _infoRow('Mwisho', _e('contract_end_date')),
                          _infoRow('Aina', _e('contract_type')),
                        ]),
                        const SizedBox(height: 14.0),
                        _buildSection(context, 'Benki', [
                          _infoRow('Benki', _e('bank_name')),
                          _infoRow('Namba ya Akaunti', _e('bank_account_number')),
                          _infoRow('Jina la Akaunti', _e('bank_account_name')),
                        ]),
                        if (_model.salary != null) ...[
                          const SizedBox(height: 14.0),
                          _buildSection(context, 'Mshahara (Sasa)', [
                            _infoRow('Msingi', 'TZS ${_fmt(_model.salary!['basic_salary'])}'),
                            _infoRow('Jumla', 'TZS ${_fmt(_model.salary!['gross_salary'])}'),
                            _infoRow('Tangu', _model.salary!['effective_from']?.toString() ?? '-'),
                          ]),
                        ],
                        const SizedBox(height: 24.0),
                        // Quick links
                        Row(
                          children: [
                            Expanded(
                              child: _quickLink(
                                context,
                                icon: Icons.receipt_long,
                                label: 'Mishahara',
                                color: const Color(0xFF059669),
                                onTap: () =>
                                    context.pushNamed(HrPayslipsWidget.routeName),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: _quickLink(
                                context,
                                icon: Icons.event_available,
                                label: 'Likizo',
                                color: const Color(0xFF3B82F6),
                                onTap: () =>
                                    context.pushNamed(HrLeaveWidget.routeName),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: _quickLink(
                                context,
                                icon: Icons.star_outline,
                                label: 'Utendaji',
                                color: const Color(0xFF8B5CF6),
                                onTap: () =>
                                    context.pushNamed(HrPerformanceWidget.routeName),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        // Sign out
                        SizedBox(
                          width: double.infinity,
                          child: FFButtonWidget(
                            onPressed: () async {
                              GoRouter.of(context).prepareAuthEvent();
                              await authManager.signOut();
                              GoRouter.of(context).clearRedirectLocation();
                              context.goNamedAuth(
                                  LoginPageWidget.routeName, context.mounted);
                            },
                            text: 'Ondoka',
                            options: FFButtonOptions(
                              height: 48.0,
                              color: const Color(0xFFEF4444),
                              textStyle: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final name = _e('full_name') ?? 'N/A';
    final initials = name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Container(
            width: 72.0,
            height: 72.0,
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            name,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
          ),
          if (_e('employee_code') != null)
            Text(
              _e('employee_code')!,
              style: GoogleFonts.inter(
                  color: const Color(0xCCFFFFFF), fontSize: 14.0),
            ),
          if (_e('dept') != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  _e('dept')!,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 10.0),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.0,
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickLink(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.0),
            const SizedBox(height: 6.0),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11.0, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  String? _e(String field) => _model.employee?[field]?.toString();

  String _fmt(dynamic value) {
    if (value == null) return '0';
    final num v = value is num ? value : 0;
    return v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
