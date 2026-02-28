// IMFSL Staff Management - FlutterFlow Custom Widget
// ===================================================
// Staff directory with search, filter, and detail view:
// - Search bar with debounced input
// - Branch and role filter dropdowns
// - Staff list with avatars, role badges, status dots
// - Bottom sheet detail view with 4 tabs
// - FAB for adding staff (ADMIN only)
//
// Dependencies (add to pubspec.yaml):
//   intl: ^0.19.0

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImfslStaffManagement extends StatefulWidget {
  const ImfslStaffManagement({
    super.key,
    this.staffList = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.currentUserRole = '',
    this.onSearch,
    this.onFilterBranch,
    this.onFilterRole,
    this.onLoadMore,
    this.onStaffTap,
    this.onAddStaff,
    this.onUpdateRole,
    this.onToggleActive,
    this.branches = const [],
    this.roles = const ['ADMIN', 'MANAGER', 'OFFICER', 'AUDITOR', 'TELLER'],
  });

  final List<Map<String, dynamic>> staffList;
  final int totalCount;
  final bool isLoading;
  final String currentUserRole;
  final Function(String)? onSearch;
  final Function(String?)? onFilterBranch;
  final Function(String?)? onFilterRole;
  final VoidCallback? onLoadMore;
  final Function(Map<String, dynamic>)? onStaffTap;
  final VoidCallback? onAddStaff;
  final Function(String staffId, String newRole)? onUpdateRole;
  final Function(String staffId, bool isActive, String reason)? onToggleActive;
  final List<String> branches;
  final List<String> roles;

  @override
  State<ImfslStaffManagement> createState() => _ImfslStaffManagementState();
}

class _ImfslStaffManagementState extends State<ImfslStaffManagement> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedBranch;
  String? _selectedRole;

  static const Color _primaryColor = Color(0xFF1565C0);

  bool get _isAdmin => widget.currentUserRole.toUpperCase() == 'ADMIN';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch?.call(query);
    });
  }

  // -- role badge colors --

  Color _roleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Colors.red;
      case 'MANAGER':
        return Colors.orange;
      case 'OFFICER':
        return _primaryColor;
      case 'AUDITOR':
        return Colors.purple;
      case 'TELLER':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // -- safe data access helpers --

  String _string(Map<String, dynamic> m, String key) =>
      (m[key] as String?) ?? '';

  bool _bool(Map<String, dynamic> m, String key) =>
      (m[key] as bool?) ?? false;

  String _initials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterRow(),
          _buildResultCount(),
          Expanded(child: _buildStaffList()),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: widget.onAddStaff,
              backgroundColor: _primaryColor,
              child: const Icon(Icons.person_add, color: Colors.white),
            )
          : null,
    );
  }

  // ========== SEARCH BAR ==========

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search staff by name, ID, or email...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: _primaryColor, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearch?.call('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ========== FILTER ROW ==========

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: _buildBranchDropdown()),
          const SizedBox(width: 12),
          Expanded(child: _buildRoleDropdown()),
        ],
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBranch,
          isExpanded: true,
          hint: Text(
            'All Branches',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          icon: Icon(Icons.expand_more, color: Colors.grey[400], size: 20),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All Branches',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ),
            ...widget.branches.map((b) => DropdownMenuItem<String>(
                  value: b,
                  child: Text(b, style: const TextStyle(fontSize: 13)),
                )),
          ],
          onChanged: (val) {
            setState(() => _selectedBranch = val);
            widget.onFilterBranch?.call(val);
          },
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          hint: Text(
            'All Roles',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          icon: Icon(Icons.expand_more, color: Colors.grey[400], size: 20),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All Roles',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ),
            ...widget.roles.map((r) => DropdownMenuItem<String>(
                  value: r,
                  child: Text(r, style: const TextStyle(fontSize: 13)),
                )),
          ],
          onChanged: (val) {
            setState(() => _selectedRole = val);
            widget.onFilterRole?.call(val);
          },
        ),
      ),
    );
  }

  // ========== RESULT COUNT ==========

  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Showing ${widget.staffList.length} of ${widget.totalCount} staff',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }

  // ========== STAFF LIST ==========

  Widget _buildStaffList() {
    if (widget.isLoading && widget.staffList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (widget.staffList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No staff found',
              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.staffList.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.staffList.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: _primaryColor),
            ),
          );
        }

        final staff = widget.staffList[index];
        return _buildStaffTile(staff);
      },
    );
  }

  Widget _buildStaffTile(Map<String, dynamic> staff) {
    final fullName = _string(staff, 'full_name');
    final position = _string(staff, 'position');
    final role = _string(staff, 'system_role');
    final branch = _string(staff, 'branch_name');
    final isActive = _bool(staff, 'is_active');
    final lastLogin = _string(staff, 'last_login');
    final photoUrl = _string(staff, 'photo_url');

    return GestureDetector(
      onTap: () {
        widget.onStaffTap?.call(staff);
        _showStaffDetailSheet(staff);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _roleColor(role).withValues(alpha: 0.15),
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? Text(
                      _initials(fullName),
                      style: TextStyle(
                        color: _roleColor(role),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Status dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              isActive ? const Color(0xFF2E7D32) : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (position.isNotEmpty)
                    Text(
                      position,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _roleColor(role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _roleColor(role),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (branch.isNotEmpty) ...[
                        Icon(Icons.business, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            branch,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (lastLogin.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last login: $lastLogin',
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300], size: 22),
          ],
        ),
      ),
    );
  }

  // ========== STAFF DETAIL BOTTOM SHEET ==========

  void _showStaffDetailSheet(Map<String, dynamic> staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _StaffDetailSheet(
          staff: staff,
          isAdmin: _isAdmin,
          roles: widget.roles,
          onUpdateRole: widget.onUpdateRole,
          onToggleActive: widget.onToggleActive,
        );
      },
    );
  }
}

// ========== Staff Detail Bottom Sheet ==========

class _StaffDetailSheet extends StatefulWidget {
  const _StaffDetailSheet({
    required this.staff,
    required this.isAdmin,
    required this.roles,
    this.onUpdateRole,
    this.onToggleActive,
  });

  final Map<String, dynamic> staff;
  final bool isAdmin;
  final List<String> roles;
  final Function(String staffId, String newRole)? onUpdateRole;
  final Function(String staffId, bool isActive, String reason)? onToggleActive;

  @override
  State<_StaffDetailSheet> createState() => _StaffDetailSheetState();
}

class _StaffDetailSheetState extends State<_StaffDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedRole;
  final TextEditingController _reasonController = TextEditingController();

  static const Color _primaryColor = Color(0xFF1565C0);

  String _string(String key) => (widget.staff[key] as String?) ?? '';
  bool _bool(String key) => (widget.staff[key] as bool?) ?? false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedRole = _string('system_role');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    _initials(_string('full_name')),
                    style: const TextStyle(
                      color: _primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _string('full_name'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _string('employee_id'),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey[500],
            indicatorColor: _primaryColor,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Access'),
              Tab(text: 'Activity'),
              Tab(text: 'Documents'),
            ],
          ),
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildAccessTab(),
                _buildActivityTab(),
                _buildDocumentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // -- Profile Tab --

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailRow('Full Name', _string('full_name')),
          _buildDetailRow('Employee ID', _string('employee_id')),
          _buildDetailRow('Email', _string('email')),
          _buildDetailRow('Phone', _string('phone')),
          _buildDetailRow('National ID', _string('national_id')),
          _buildDetailRow('Position', _string('position')),
          _buildDetailRow('Department', _string('department')),
          _buildDetailRow('Branch', _string('branch_name')),
          _buildDetailRow('Role', _string('system_role')),
          _buildDetailRow(
              'Status', _bool('is_active') ? 'Active' : 'Inactive'),
          _buildDetailRow('Date Joined', _string('date_joined')),
          _buildDetailRow('Last Login', _string('last_login')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // -- Access Tab --

  Widget _buildAccessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Role',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                items: widget.roles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r, style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: widget.isAdmin
                    ? (val) => setState(() => _selectedRole = val)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.isAdmin)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedRole != null) {
                    final staffId = _string('staff_id').isNotEmpty
                        ? _string('staff_id')
                        : _string('id');
                    widget.onUpdateRole?.call(staffId, _selectedRole!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Update Role'),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Account Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _bool('is_active')
                      ? const Color(0xFF2E7D32)
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _bool('is_active') ? 'Active' : 'Inactive',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (widget.isAdmin) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Reason for status change',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final staffId = _string('staff_id').isNotEmpty
                      ? _string('staff_id')
                      : _string('id');
                  widget.onToggleActive?.call(
                    staffId,
                    !_bool('is_active'),
                    _reasonController.text,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      _bool('is_active') ? Colors.red : const Color(0xFF2E7D32),
                  side: BorderSide(
                    color: _bool('is_active')
                        ? Colors.red
                        : const Color(0xFF2E7D32),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _bool('is_active') ? 'Deactivate Account' : 'Activate Account',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -- Activity Tab --

  Widget _buildActivityTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Activity log for this staff member',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Load Activity Log'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(color: _primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Documents Tab --

  Widget _buildDocumentsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Staff documents will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload and manage ID copies, contracts, and certifications',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
