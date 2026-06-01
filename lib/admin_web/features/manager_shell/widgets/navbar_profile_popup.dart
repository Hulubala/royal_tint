import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';

class NavbarProfilePopup extends StatelessWidget {
  final VoidCallback onClose;

  const NavbarProfilePopup({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
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
        children: [
          _ProfileMenuItem(
            icon: BootstrapIcons.person_circle,
            label: 'My Profile',
            hoverColor: const Color(0xFFFFD700),
            textColor: const Color(0xFFFFD700),
            hoverTextColor: Colors.black,
            isFirst: true,
            onTap: () {
              onClose();
              context.go('/manager/profile');
            },
          ),
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, Color(0xFFFFD700), Colors.transparent]),
            ),
          ),
          _ProfileMenuItem(
            icon: BootstrapIcons.box_arrow_right,
            label: 'Logout',
            hoverColor: const Color(0xFFFF6B6B),
            textColor: const Color(0xFFFF6B6B),
            hoverTextColor: Colors.white,
            isLast: true,
            onTap: () {
              onClose();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                  ),
                  title: const Text('Confirm Logout', style: TextStyle(color: Color(0xFFFFD700))),
                  content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<AuthProvider>().signOut();
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
          splashColor: widget.hoverColor.withValues(alpha: 0.5),
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
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
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
