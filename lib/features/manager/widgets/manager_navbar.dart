import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/features/manager/providers/manager_provider.dart';

class ManagerNavbar extends StatefulWidget {
  const ManagerNavbar({super.key});

  @override
  State<ManagerNavbar> createState() => _ManagerNavbarState();
}

class _ManagerNavbarState extends State<ManagerNavbar> {
  // Overlay controllers
  OverlayEntry? _notificationOverlay;
  OverlayEntry? _profileOverlay;
  
  // Keys for positioning
  final GlobalKey _notificationKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  
  // Get notification count from ManagerProvider
  int get unreadCount {
    try {
      final managerProvider = Provider.of<ManagerProvider>(context, listen: false);
      return managerProvider.todayAppointments;
    } catch (e) {
      return 0;
    }
  }

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
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFD700), width: 3),
        ),
      ),
      child: Row(
        children: [
          // Left Section - Grid Icon + Title
          const Row(
            children: [
              Icon(
                BootstrapIcons.grid_3x3_gap_fill,
                color: Color(0xFFFFD700),
                size: 22,
              ),
              SizedBox(width: 12),
              Text(
                'Royal Tint Manager',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Right Section
          Row(
            children: [
              _buildNotificationIcon(),
              const SizedBox(width: 16),
              _buildUserProfile(),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // NOTIFICATION OVERLAY METHODS
  // ============================================

  void _showNotificationOverlay() {
    final RenderBox? renderBox = _notificationKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _notificationOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to detect clicks outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideNotificationOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Notification popup
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
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _buildNotificationPopup(),
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
    return MouseRegion(
      key: _notificationKey,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (_notificationOverlay == null) {
            _showNotificationOverlay();
          } else {
            _hideNotificationOverlay();
          }
        },
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700).withOpacity(0.1),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  BootstrapIcons.bell_fill,
                  color: Color(0xFFFFD700),
                  size: 18,
                ),
              ),
              if (unreadCount > 0)
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
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildNotificationPopup() {
    return Container(
      width: 380,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Color(0xFF1A1A1A)],
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFFFD700), width: 2),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Icon(BootstrapIcons.bell, color: Color(0xFFFFD700), size: 18),
                SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Simple notification message - CENTERED
          Consumer<ManagerProvider>(
            builder: (context, managerProvider, child) {
              if (managerProvider.todayAppointments == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          BootstrapIcons.calendar_x,
                          color: Colors.grey,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No appointments today',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      BootstrapIcons.calendar_check_fill,
                      color: Color(0xFFFFD700),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You have ${managerProvider.todayAppointments} appointment${managerProvider.todayAppointments == 1 ? '' : 's'} today',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        _hideNotificationOverlay();
                        context.go('/manager/appointments');
                      },
                      icon: const Icon(BootstrapIcons.calendar3, size: 16),
                      label: const Text('View All Appointments'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // PROFILE OVERLAY METHODS
  // ============================================

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
          // Invisible barrier to detect clicks outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideProfileOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Profile popup
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
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _buildProfilePopup(),
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
    return MouseRegion(
      key: _profileKey,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (_profileOverlay == null) {
            _showProfileOverlay();
          } else {
            _hideProfileOverlay();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFFFD700),
                radius: 18,
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Admin',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                BootstrapIcons.chevron_down,
                color: Color(0xFFFFD700),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePopup() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // My Profile - Gold hover with black text
          _ProfileMenuItem(
            icon: BootstrapIcons.person_circle,
            label: 'My Profile',
            hoverColor: const Color(0xFFFFD700),
            textColor: const Color(0xFFFFD700),
            hoverTextColor: Colors.black,
            isFirst: true,
            onTap: () {
              _hideProfileOverlay();
              context.go('/manager/profile');
            },
          ),
          
          // Gradient Divider
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFFFD700),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Logout - Red hover with white text
          _ProfileMenuItem(
            icon: BootstrapIcons.box_arrow_right,
            label: 'Logout',
            hoverColor: const Color(0xFFFF6B6B),
            textColor: const Color(0xFFFF6B6B),
            hoverTextColor: Colors.white,
            isLast: true,
            onTap: () {
              _hideProfileOverlay();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                  ),
                  title: const Text(
                    'Confirm Logout',
                    style: TextStyle(color: Color(0xFFFFD700)),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.signOut();
                        // Navigation happens automatically via router
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================
// REUSABLE PROFILE MENU ITEM WIDGET
// ============================================

class _ProfileMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color hoverColor;
  final Color textColor;
  final Color hoverTextColor;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.hoverColor,
    required this.textColor,
    required this.hoverTextColor,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<_ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<_ProfileMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          hoverColor: widget.hoverColor,
          splashColor: widget.hoverColor.withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: widget.isFirst ? const Radius.circular(10) : Radius.zero,
            topRight: widget.isFirst ? const Radius.circular(10) : Radius.zero,
            bottomLeft: widget.isLast ? const Radius.circular(10) : Radius.zero,
            bottomRight: widget.isLast ? const Radius.circular(10) : Radius.zero,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: widget.isFirst
                  ? Border(
                      bottom: BorderSide(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: isHovered ? widget.hoverTextColor : widget.textColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: isHovered ? widget.hoverTextColor : widget.textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}