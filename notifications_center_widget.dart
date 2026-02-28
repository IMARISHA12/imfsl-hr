import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// NotificationsCenterWidget displays a notification inbox with unread/all
/// filtering, swipe-to-dismiss, infinite scroll, pull-to-refresh, and
/// relative timestamps for the IMFSL microfinance customer mobile app.
class NotificationsCenterWidget extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final int unreadCount;
  final Future<List<Map<String, dynamic>>> Function(
      int offset, bool unreadOnly)? onLoadMore;
  final Future<void> Function(String notificationId)? onMarkRead;
  final Future<void> Function()? onMarkAllRead;
  final Function(Map<String, dynamic> notification)? onNotificationTap;

  const NotificationsCenterWidget({
    super.key,
    this.notifications = const [],
    this.unreadCount = 0,
    this.onLoadMore,
    this.onMarkRead,
    this.onMarkAllRead,
    this.onNotificationTap,
  });

  @override
  State<NotificationsCenterWidget> createState() =>
      _NotificationsCenterWidgetState();
}

class _NotificationsCenterWidgetState extends State<NotificationsCenterWidget> {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const Color _unreadBgColor = Color(0xFFF5F9FF);

  late ScrollController _scrollController;
  late List<Map<String, dynamic>> _allNotifications;
  bool _showUnreadOnly = false;
  bool _isLoadingMore = false;
  bool _isMarkingAllRead = false;
  int _localUnreadCount = 0;

  // Track which notifications have been locally marked as read
  final Set<String> _locallyMarkedRead = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _allNotifications = List<Map<String, dynamic>>.from(widget.notifications);
    _localUnreadCount = widget.unreadCount;
  }

  @override
  void didUpdateWidget(covariant NotificationsCenterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notifications != oldWidget.notifications) {
      _allNotifications = List<Map<String, dynamic>>.from(widget.notifications);
      _locallyMarkedRead.clear();
    }
    if (widget.unreadCount != oldWidget.unreadCount) {
      _localUnreadCount = widget.unreadCount;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isNotificationRead(Map<String, dynamic> notification) {
    final id = notification['id']?.toString() ?? '';
    if (_locallyMarkedRead.contains(id)) return true;
    return notification['is_read'] == true;
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_showUnreadOnly) {
      return _allNotifications
          .where((n) => !_isNotificationRead(n))
          .toList();
    }
    return _allNotifications;
  }

  int get _effectiveUnreadCount {
    return max(0, _localUnreadCount - _locallyMarkedRead.length);
  }

  // ---------------------------------------------------------------------------
  // Notification type styling
  // ---------------------------------------------------------------------------

  IconData _typeIcon(String type) {
    switch (type) {
      case 'loan_status':
        return Icons.account_balance;
      case 'payment_received':
        return Icons.check_circle;
      case 'payment_reminder':
        return Icons.alarm;
      case 'kyc_update':
        return Icons.verified_user;
      case 'system':
        return Icons.info;
      case 'loan_overdue':
        return Icons.warning;
      case 'savings_interest':
        return Icons.savings;
      default:
        return Icons.notifications;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'loan_status':
        return _primaryColor;
      case 'payment_received':
        return Colors.green;
      case 'payment_reminder':
        return Colors.amber.shade700;
      case 'kyc_update':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      case 'loan_overdue':
        return Colors.red;
      case 'savings_interest':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'loan_status':
        return 'Loan Status Update';
      case 'payment_received':
        return 'Payment Received';
      case 'payment_reminder':
        return 'Payment Reminder';
      case 'kyc_update':
        return 'KYC Update';
      case 'system':
        return 'System Notification';
      case 'loan_overdue':
        return 'Loan Overdue';
      case 'savings_interest':
        return 'Savings Interest';
      default:
        return type
            .split('_')
            .map((w) => w.isNotEmpty
                ? '${w[0].toUpperCase()}${w.substring(1)}'
                : '')
            .join(' ');
    }
  }

  // ---------------------------------------------------------------------------
  // Relative timestamp
  // ---------------------------------------------------------------------------

  String _relativeTimestamp(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) return DateFormat('dd MMM').format(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    // Check if yesterday
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly == yesterday) return 'Yesterday';

    // Check if this week (within last 7 days)
    if (diff.inDays < 7) {
      return DateFormat('EEEE').format(date); // Day name, e.g., "Monday"
    }

    return DateFormat('dd MMM').format(date);
  }

  // ---------------------------------------------------------------------------
  // Scroll / Load More
  // ---------------------------------------------------------------------------

  void _onScroll() {
    if (_isLoadingMore || widget.onLoadMore == null) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final currentPosition = _scrollController.position.pixels;
    if (maxExtent > 0 && currentPosition >= maxExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final newItems = await widget.onLoadMore!(
        _allNotifications.length,
        _showUnreadOnly,
      );
      if (mounted && newItems.isNotEmpty) {
        setState(() {
          _allNotifications.addAll(newItems);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh
  // ---------------------------------------------------------------------------

  Future<void> _handleRefresh() async {
    if (widget.onLoadMore == null) return;
    try {
      final freshItems = await widget.onLoadMore!(0, _showUnreadOnly);
      if (mounted) {
        setState(() {
          _allNotifications = freshItems;
          _locallyMarkedRead.clear();
          _localUnreadCount = widget.unreadCount;
        });
      }
    } catch (_) {
      // Silently handle refresh errors
    }
  }

  // ---------------------------------------------------------------------------
  // Mark as read
  // ---------------------------------------------------------------------------

  Future<void> _markAsRead(String notificationId) async {
    setState(() {
      _locallyMarkedRead.add(notificationId);
    });
    if (widget.onMarkRead != null) {
      try {
        await widget.onMarkRead!(notificationId);
      } catch (_) {
        // If the remote call fails, keep the local state for UX
      }
    }
  }

  Future<void> _markAllRead() async {
    if (widget.onMarkAllRead == null) return;
    setState(() => _isMarkingAllRead = true);
    try {
      await widget.onMarkAllRead!();
      if (mounted) {
        setState(() {
          for (final n in _allNotifications) {
            final id = n['id']?.toString() ?? '';
            if (id.isNotEmpty) _locallyMarkedRead.add(id);
          }
          _localUnreadCount = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isMarkingAllRead = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Tap handler
  // ---------------------------------------------------------------------------

  void _onTapNotification(Map<String, dynamic> notification) {
    final id = notification['id']?.toString() ?? '';
    if (!_isNotificationRead(notification) && id.isNotEmpty) {
      _markAsRead(id);
    }
    widget.onNotificationTap?.call(notification);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    final unread = _effectiveUnreadCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
      child: Row(
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Text(
                unread > 99 ? '99+' : unread.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          const Spacer(),
          if (unread > 0)
            TextButton(
              onPressed: _isMarkingAllRead ? null : _markAllRead,
              child: _isMarkingAllRead
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _primaryColor,
                      ),
                    )
                  : const Text(
                      'Mark All Read',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tabs (Unread / All)
  // ---------------------------------------------------------------------------

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildTabButton(
            label: 'Unread',
            isActive: _showUnreadOnly,
            onTap: () {
              if (!_showUnreadOnly) {
                setState(() => _showUnreadOnly = true);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            label: 'All',
            isActive: !_showUnreadOnly,
            onTap: () {
              if (_showUnreadOnly) {
                setState(() => _showUnreadOnly = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? _primaryColor : Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2.5,
            width: 40,
            decoration: BoxDecoration(
              color: isActive ? _primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody() {
    final filtered = _filteredNotifications;

    // Empty states
    if (_allNotifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        title: 'No notifications yet',
        subtitle: 'Your notifications will appear here.',
      );
    }

    if (_showUnreadOnly && filtered.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'All caught up!',
        subtitle: 'You have no unread notifications.',
      );
    }

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: filtered.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return _buildLoadingIndicator();
          }
          return _buildNotificationItem(filtered[index]);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: _primaryColor,
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Loading Indicator (infinite scroll)
  // ---------------------------------------------------------------------------

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: _primaryColor,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notification Item
  // ---------------------------------------------------------------------------

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final id = notification['id']?.toString() ?? '';
    final type = notification['notification_type']?.toString() ?? 'system';
    final messageBody = notification['message_body']?.toString() ?? '';
    final createdAt = notification['created_at']?.toString();
    final isRead = _isNotificationRead(notification);

    return Dismissible(
      key: ValueKey(id.isNotEmpty ? id : notification.hashCode),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        if (!isRead && id.isNotEmpty) {
          await _markAsRead(id);
        }
        return false; // Don't actually remove from list, just mark as read
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: Colors.green,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Mark Read',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: () => _onTapNotification(notification),
        child: Container(
          color: isRead ? Colors.white : _unreadBgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading icon
              _buildTypeAvatar(type),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _typeLabel(type),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Relative timestamp
                        Text(
                          _relativeTimestamp(createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Message body
                    Text(
                      messageBody,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread dot
              if (!isRead) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Type Avatar
  // ---------------------------------------------------------------------------

  Widget _buildTypeAvatar(String type) {
    final color = _typeColor(type);
    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withOpacity(0.12),
      child: Icon(
        _typeIcon(type),
        color: color,
        size: 20,
      ),
    );
  }
}
