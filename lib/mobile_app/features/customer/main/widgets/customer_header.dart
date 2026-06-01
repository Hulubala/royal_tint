import 'package:flutter/material.dart';
import 'package:royal_tint/data/repositories/customer_repository.dart';
import 'package:royal_tint/domain/models/user/customer_model.dart';
import 'package:royal_tint/domain/models/notification_model.dart';
import 'package:royal_tint/data/services/notification_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class CustomerHeader extends StatelessWidget {
  final String title;
  final bool showCustomerInfo;
  final VoidCallback? onBack;

  const CustomerHeader({
    super.key,
    required this.title,
    this.showCustomerInfo = false,
    this.onBack,
  });

  static const _gold = Color(0xFFFFD700);
  static const _surface = Colors.black;

  @override
  Widget build(BuildContext context) {
    final customerRepo = CustomerRepository();
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 20
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 15, 20, 25),
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: Border(
          bottom: BorderSide(color: _gold, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: showCustomerInfo
          ? StreamBuilder<CustomerModel>(
              stream: CustomerRepository().streamCurrentCustomer(),
              builder: (context, snap) {
                final customer = snap.data;
                final name = customer?.name ?? '...';
                final uid = customer?.uid ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo icon and title
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 36,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const CircleAvatar(
                                backgroundColor: _gold,
                                radius: 18,
                                child: Icon(BootstrapIcons.droplet_fill, color: Colors.black, size: 16),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Royal Tint',
                              style: TextStyle(
                                color: _gold,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        // Notification Bell Icon with real-time badge
                        _NotificationBellButton(customerUID: uid),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (onBack != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _gold, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Notification bell button with unread badge and bottom sheet
class _NotificationBellButton extends StatelessWidget {
  final String customerUID;
  const _NotificationBellButton({required this.customerUID});

  static const _gold = Color(0xFFFFD700);
  static const _surface = Colors.black;

  @override
  Widget build(BuildContext context) {
    if (customerUID.isEmpty) {
      return const Icon(BootstrapIcons.bell, color: _gold, size: 20);
    }

    final notificationService = NotificationService();

    return StreamBuilder<int>(
      stream: notificationService.getUnreadCountStream(customerUID),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () => _showNotificationSheet(context, customerUID),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(BootstrapIcons.bell, color: _gold, size: 20),
              if (count > 0)
                Positioned(
                  top: -6,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: _surface, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationSheet(BuildContext context, String uid) {
    final notificationService = NotificationService();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      const Icon(BootstrapIcons.bell_fill, color: _gold, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Notifications',
                        style: TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          notificationService.markAllAsRead(uid);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: _gold.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: _gold, height: 1, thickness: 0.5),

                // Notification list
                Flexible(
                  child: StreamBuilder<List<NotificationModel>>(
                    stream: notificationService.getNotificationsStream(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: _gold));
                      }

                      final notifications = snapshot.data ?? [];
                      if (notifications.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(BootstrapIcons.bell_slash, color: _gold.withOpacity(0.3), size: 44),
                                const SizedBox(height: 14),
                                Text(
                                  'No notifications yet',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.06), height: 1),
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          return _buildNotificationTile(context, n, notificationService);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationModel n, NotificationService service) {
    IconData icon;
    Color iconColor;
    switch (n.type) {
      case 'appointment_created':
        icon = BootstrapIcons.calendar_plus_fill;
        iconColor = const Color(0xFF4CAF50);
        break;
      case 'status_changed':
        if (n.title.contains('Confirmed')) {
          icon = BootstrapIcons.check_circle_fill;
          iconColor = const Color(0xFF4CAF50);
        } else if (n.title.contains('Cancelled')) {
          icon = BootstrapIcons.x_circle_fill;
          iconColor = Colors.redAccent;
        } else if (n.title.contains('Completed')) {
          icon = BootstrapIcons.trophy_fill;
          iconColor = _gold;
        } else {
          icon = BootstrapIcons.arrow_repeat;
          iconColor = _gold;
        }
        break;
      default:
        icon = BootstrapIcons.bell_fill;
        iconColor = _gold;
    }

    return GestureDetector(
      onTap: () {
        if (!n.isRead) {
          service.markAsRead(n.notificationID);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: n.isRead ? Colors.transparent : _gold.withOpacity(0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: TextStyle(
                      color: n.isRead ? Colors.grey : Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.timeAgo,
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
