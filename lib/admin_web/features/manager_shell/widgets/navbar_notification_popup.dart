import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/domain/models/notification_model.dart';
import 'package:royal_tint/data/services/notification_service.dart';

class NavbarNotificationPopup extends StatelessWidget {
  final VoidCallback onClose;
  
  const NavbarNotificationPopup({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final managerUID = authProvider.manager?.uid ?? '';
    final branchID = authProvider.manager?.branchID;
    final notificationService = NotificationService();

    return Container(
      width: 400,
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
              border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 2)),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.bell, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 8),
                const Text('Notifications', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      notificationService.markAllAsRead(managerUID, branchID);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification list
          Flexible(
            child: StreamBuilder<List<NotificationModel>>(
              stream: notificationService.getNotificationsStream(managerUID, branchID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
                  );
                }

                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 44, horizontal: 28),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(BootstrapIcons.bell_slash, color: Colors.grey, size: 44),
                          SizedBox(height: 14),
                          Text(
                            'No notifications yet',
                            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => Divider(color: const Color(0xFFFFD700).withValues(alpha: 0.15), height: 1),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return _buildNotificationItem(context, n, notificationService);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel n, NotificationService notificationService) {
    IconData icon;
    Color iconColor;
    switch (n.type) {
      case 'appointment_created':
        icon = BootstrapIcons.calendar_plus_fill;
        iconColor = const Color(0xFF4CAF50);
        break;
      case 'appointment_cancelled':
        icon = BootstrapIcons.x_circle_fill;
        iconColor = Colors.red;
        break;
      case 'status_changed':
        icon = BootstrapIcons.arrow_repeat;
        iconColor = const Color(0xFFFFC107);
        break;
      default:
        icon = BootstrapIcons.bell_fill;
        iconColor = const Color(0xFFFFD700);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (!n.isRead) {
            notificationService.markAsRead(n.notificationID);
          }
          // Navigate to appointments page and auto-open the specific appointment
          onClose();
          context.go('/manager/appointments?id=${n.appointmentID}');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: n.isRead ? Colors.transparent : const Color(0xFFFFD700).withValues(alpha: 0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
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
                              fontSize: 12,
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
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.message,
                      style: TextStyle(
                        color: n.isRead ? Colors.grey : Colors.white70,
                        fontSize: 11,
                        height: 1.3,
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
      ),
    );
  }
}
