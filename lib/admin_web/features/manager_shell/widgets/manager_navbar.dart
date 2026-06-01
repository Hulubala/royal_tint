import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/data/services/notification_service.dart';
import 'package:royal_tint/admin_web/features/manager_shell/widgets/navbar_notification_popup.dart';
import 'package:royal_tint/admin_web/features/manager_shell/widgets/navbar_profile_popup.dart';

class ManagerNavbar extends StatefulWidget {
  const ManagerNavbar({super.key});

  @override
  State<ManagerNavbar> createState() => _ManagerNavbarState();
}

class _ManagerNavbarState extends State<ManagerNavbar> {
  OverlayEntry? _notificationOverlay;
  OverlayEntry? _profileOverlay;

  final GlobalKey _notificationKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _hideNotificationOverlay();
    _hideProfileOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 3)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Row(
              children: [
                Icon(BootstrapIcons.grid_3x3_gap_fill, color: Color(0xFFFFD700), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Royal Tint Manager',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),  
              ],
            ),
          ),

          const SizedBox(width: 12),
          
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                _buildNotificationIcon(),
                const SizedBox(width: 16),
                _buildUserProfile(),
              ],
            ),
          ),  
        ],
      ),
    );
  }

  // ================= Notifications =================

  void _showNotificationOverlay() {
    final RenderBox? renderBox = _notificationKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _notificationOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideNotificationOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: position.dy + size.height + 8,
            left: position.dx - 338,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.95 + (0.05 * value),
                    alignment: Alignment.topRight,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: NavbarNotificationPopup(onClose: _hideNotificationOverlay),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_notificationOverlay!);
  }

  void _hideNotificationOverlay() {
    _notificationOverlay?.remove();
    _notificationOverlay = null;
  }

  Widget _buildNotificationIcon() {
    final authProvider = context.read<AuthProvider>();
    final managerUID = authProvider.manager?.uid;
    final branchID = authProvider.manager?.branchID;
    if (managerUID == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: _notificationService.getUnreadCountStream(managerUID, branchID),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        return MouseRegion(
          key: _notificationKey,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _notificationOverlay == null ? _showNotificationOverlay() : _hideNotificationOverlay(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(BootstrapIcons.bell_fill, color: Color(0xFFFFD700), size: 18),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3545),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Center(
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  // ================= Profile =================

  void _showProfileOverlay() {
    final RenderBox? renderBox = _profileKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    const dropdownWidth = 250.0;
    final dropdownLeft = position.dx + size.width - dropdownWidth;

    _profileOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideProfileOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: position.dy + size.height + 8,
            left: dropdownLeft,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.95 + (0.05 * value),
                    alignment: Alignment.topRight,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: NavbarProfilePopup(onClose: _hideProfileOverlay),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_profileOverlay!);
  }

  void _hideProfileOverlay() {
    _profileOverlay?.remove();
    _profileOverlay = null;
  }

  Widget _buildUserProfile() {
    final authProvider = context.read<AuthProvider>();
    final name = authProvider.manager?.name ?? 'Manager';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return MouseRegion(
      key: _profileKey,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _profileOverlay == null ? _showProfileOverlay() : _hideProfileOverlay(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFD700),
                radius: 18,
                child: Text(
                  initial,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140), 
                  child: Text(
                    name, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(
                      color: Color(0xFFFFD700), 
                      fontWeight: FontWeight.w600, 
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(width: 6),
                const Icon(BootstrapIcons.chevron_down, color: Color(0xFFFFD700), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}