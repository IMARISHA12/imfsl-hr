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
import 'hr_payslips_model.dart';
export 'hr_payslips_model.dart';

/// My Payslips — Shows current salary, payslip history, and salary loans.
///
/// TAB 1 (Mshahara): Current salary breakdown card
/// TAB 2 (Historia): Payslip list with month, gross, net, status
/// TAB 3 (Mikopo): Active staff salary loans
class HrPayslipsWidget extends StatefulWidget {
  const HrPayslipsWidget({super.key});

  static String routeName = 'HrPayslips';
  static String routePath = '/hrPayslips';

  @override
  State<HrPayslipsWidget> createState() => _HrPayslipsWidgetState();
}

class _HrPayslipsWidgetState extends State<HrPayslipsWidget>
    with SingleTickerProviderStateMixin {
  late HrPayslipsModel _model;
  late TabController _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrPayslipsModel());
    _tabController = TabController(length: 3, vsync: this);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _resolveEmployeeId();
      await _loadData();
    });
  }

  Future<void> _resolveEmployeeId() async {
    final rows = await EmployeesTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid).limit(1),
    );
    if (rows.isNotEmpty) {
      _employeeId = rows.first.id;
    }
  }

  Future<void> _loadData() async {
    if (_employeeId == null) {
      _model.isLoading = false;
      _model.errorMessage = 'Akaunti yako haijapatikana. Wasiliana na HR.';
      safeSetState(() {});
      return;
    }
    try {
      final salary = await HrService.instance.getMySalary(_employeeId!);
      final payslips = await HrService.instance.getMyPayslips(_employeeId!);
      final loans = await HrService.instance.getMyLoans(_employeeId!);
      _model.currentSalary = salary;
      _model.payslips = payslips;
      _model.loans = loans;
      _model.isLoading = false;
    } catch (e) {
      _model.isLoading = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hitilafu kupakia data: $e')),
        );
      }
    }
    safeSetState(() {});
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
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
            'Mishahara Yangu',
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
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0x99FFFFFF),
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Mshahara'),
              Tab(text: 'Historia'),
              Tab(text: 'Mikopo'),
            ],
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
            : _model.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48.0, color: Color(0xFFEF4444)),
                          const SizedBox(height: 16.0),
                          Text(
                            _model.errorMessage!,
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildSalaryTab(context),
                  _buildHistoryTab(context),
                  _buildLoansTab(context),
                ],
              ),
      ),
    );
  }

  // ── TAB 1: Current Salary ────────────────────────────────────────────

  Widget _buildSalaryTab(BuildContext context) {
    final s = _model.currentSalary;
    if (s == null) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Text(
                  'Hakuna muundo wa mshahara uliowekwa',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Gross salary header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                Text(
                  'Mshahara Jumla',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: const Color(0xCCFFFFFF),
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'TZS ${_fmt(s['gross_salary'])}',
                  style: FlutterFlowTheme.of(context).headlineLarge.override(
                        font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold),
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          // Breakdown card
          _breakdownCard(context, 'Mapato', [
            _lineItem('Mshahara Msingi', s['basic_salary']),
            _lineItem('Posho ya Nyumba', s['housing_allowance']),
            _lineItem('Posho ya Usafiri', s['transport_allowance']),
            _lineItem('Posho ya Chakula', s['meal_allowance']),
            _lineItem('Posho ya Matibabu', s['medical_allowance']),
            _lineItem('Posho ya Mawasiliano', s['communication_allowance']),
            _lineItem('Posho Nyingine', s['other_allowances']),
          ]),
        ],
      ),
      ),
    );
  }

  Widget _breakdownCard(
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
          const SizedBox(height: 12.0),
          ...rows,
        ],
      ),
    );
  }

  Widget _lineItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
          Text(
            'TZS ${_fmt(value)}',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  // ── TAB 2: Payslip History ───────────────────────────────────────────

  Widget _buildHistoryTab(BuildContext context) {
    if (_model.payslips.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Text(
                  'Hakuna stakabadhi za mshahara bado',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: _model.payslips.length,
      itemBuilder: (context, index) {
        final ps = _model.payslips[index];
        final runs = ps['payroll_runs'] as Map<String, dynamic>? ?? {};
        final status = ps['payment_status'] ?? 'pending';
        final isPaid = status == 'paid';

        return GestureDetector(
          onTap: () {
            _model.selectedPayslip = ps;
            safeSetState(() {});
            _showPayslipDetail(context, ps);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      runs['month'] ?? 'N/A',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Jumla: TZS ${_fmt(ps['gross_salary'])}',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color:
                                FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TZS ${_fmt(ps['net_salary'])}',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.inter(
                                fontWeight: FontWeight.bold),
                            color: const Color(0xFF059669),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 2.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0x1A059669)
                            : const Color(0x1AF59E0B),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        isPaid ? 'Imelipwa' : 'Inasubiri',
                        style: TextStyle(
                          color: isPaid
                              ? const Color(0xFF059669)
                              : const Color(0xFFF59E0B),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }

  void _showPayslipDetail(BuildContext context, Map<String, dynamic> ps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Stakabadhi ya Mshahara',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      font: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold),
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(height: 16.0),
              _breakdownCard(context, 'Mapato', [
                _lineItem('Mshahara Msingi', ps['basic_salary']),
                _lineItem('Posho ya Nyumba', ps['housing_allowance']),
                _lineItem('Posho ya Usafiri', ps['transport_allowance']),
                _lineItem('Posho ya Chakula', ps['meal_allowance']),
                _lineItem('Posho ya Matibabu', ps['medical_allowance']),
                _lineItem('Posho ya Mawasiliano', ps['communication_allowance']),
                _lineItem('Nyingine', ps['other_allowances']),
                _lineItem('Overtime', ps['overtime_pay']),
                _lineItem('Bonus', ps['bonus']),
                const Divider(),
                _lineItem('JUMLA', ps['gross_salary']),
              ]),
              const SizedBox(height: 12.0),
              _breakdownCard(context, 'Makato', [
                _lineItem('PAYE', ps['paye_tax']),
                _lineItem('NSSF (Mfanyakazi)', ps['nssf_employee']),
                _lineItem('WCF', ps['wcf_contribution']),
                _lineItem('SDL', ps['sdl_contribution']),
                _lineItem('HESLB', ps['heslb_deduction']),
                _lineItem('Mkopo', ps['loan_deduction']),
                _lineItem('Nyingine', ps['other_deductions']),
                const Divider(),
                _lineItem('JUMLA MAKATO', ps['total_deductions']),
              ]),
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Text('Mshahara Halisi',
                        style: GoogleFonts.inter(
                            color: const Color(0xCCFFFFFF), fontSize: 14.0)),
                    Text(
                      'TZS ${_fmt(ps['net_salary'])}',
                      style: GoogleFonts.interTight(
                        color: Colors.white,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TAB 3: Salary Loans ──────────────────────────────────────────────

  Widget _buildLoansTab(BuildContext context) {
    if (_model.loans.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Text(
                  'Hakuna mikopo ya mshahara',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: _model.loans.length,
      itemBuilder: (context, index) {
        final loan = _model.loans[index];
        final isActive = loan['status'] == 'active';
        final progress = (loan['remaining_balance'] is num &&
                loan['approved_amount'] is num &&
                (loan['approved_amount'] as num) > 0)
            ? 1.0 -
                ((loan['remaining_balance'] as num) /
                    (loan['approved_amount'] as num))
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loan['purpose'] ?? 'Mkopo wa Mshahara',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font:
                              GoogleFonts.inter(fontWeight: FontWeight.w600),
                          letterSpacing: 0.0,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0x1A3B82F6)
                          : const Color(0x1A059669),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      isActive ? 'Inaendelea' : 'Imekamilika',
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF059669),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _loanStat('Kiasi', 'TZS ${_fmt(loan['approved_amount'])}'),
                  _loanStat('Baki', 'TZS ${_fmt(loan['remaining_balance'])}'),
                  _loanStat('Kwa Mwezi', 'TZS ${_fmt(loan['monthly_installment'])}'),
                ],
              ),
              const SizedBox(height: 10.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF3B82F6)),
                  minHeight: 6.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% imelipwa',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        );
      },
      ),
    );
  }

  Widget _loanStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11.0, color: const Color(0xFF9CA3AF))),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13.0, fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _fmt(dynamic value) {
    if (value == null) return '0';
    final num v = value is num ? value : 0;
    return v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
