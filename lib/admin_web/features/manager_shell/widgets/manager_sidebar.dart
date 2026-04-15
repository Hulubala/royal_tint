import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class ManagerSidebar extends StatefulWidget {
  final String currentRoute;
  
  const ManagerSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  State<ManagerSidebar> createState() => _ManagerSidebarState();
}

class _ManagerSidebarState extends State<ManagerSidebar> {
  bool isCollapsed = false;
  String? expandedSubmenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 70 : 300,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          right: BorderSide(color: Color(0xFFFFD700), width: 3),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Header
          _buildHeader(),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              children: [
                _buildMenuItem(
                  icon: BootstrapIcons.house_door_fill,
                  label: 'Dashboard',
                  route: '/manager/dashboard',
                ),
                _buildSubmenuItem(
                  icon: BootstrapIcons.box_seam,
                  label: 'Product Management',
                  submenuKey: 'product',
                  submenuItems: [
                    {'label': 'Product Code', 'route': '/manager/product-code'},
                    {'label': 'Stock Cut Film', 'route': '/manager/stock-cut-film'},
                    {'label': 'Edit Package', 'route': '/manager/edit-package'},
                  ],
                ),
                _buildMenuItem(
                  icon: BootstrapIcons.calendar_check,
                  label: 'Appointments',
                  route: '/manager/appointments',
                ),
                _buildSubmenuItem(
                  icon: BootstrapIcons.people_fill,
                  label: 'Staff Management',
                  submenuKey: 'staff',
                  submenuItems: [
                    {'label': 'Register New Staff', 'route': '/manager/staff-registration'},
                    {'label': 'Staff Tasks', 'route': '/manager/staff-tasks'},
                  ],
                ),
                _buildMenuItem(
                  icon: BootstrapIcons.clock_history,
                  label: 'Service History',
                  route: '/manager/service-history',
                ),
                _buildMenuItem(
                  icon: BootstrapIcons.graph_up,
                  label: 'Sales & Reports',
                  route: '/manager/sales-reports',
                ),
                _buildMenuItem(
                  icon: BootstrapIcons.star_fill,
                  label: 'Customer Feedbacks',
                  route: '/manager/feedback',
                ),
              ],
            ),
          ),
          
          // Collapse Button
          _buildCollapseButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 10 : 24),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback icon if image not found
                  return Container(
                    color: const Color(0xFFFFD700),
                    child: const Icon(
                      BootstrapIcons.car_front_fill,
                      color: Colors.black,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),  

          if (!isCollapsed) ...[
            const SizedBox(width: 16),
            const Text(
              'Royal Tint',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = widget.currentRoute == route;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => context.go(route),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8 : 24,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFD700) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? const Color(0xFFFFD700) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.black : const Color(0xFFE0E0E0),
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.black : const Color(0xFFE0E0E0),
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildSubmenuItem({
    required IconData icon,
    required String label,
    required String submenuKey,
    required List<Map<String, String>> submenuItems,
  }) {
    final isExpanded = expandedSubmenu == submenuKey;
    final hasActiveSubmenu = submenuItems.any((item) => item['route'] == widget.currentRoute);
    
    if (isCollapsed) {
      // In collapsed mode, just show as regular menu item
      return _buildMenuItem(
        icon: icon,
        label: label,
        route: submenuItems.first['route']!,
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expandedSubmenu = isExpanded ? null : submenuKey;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: hasActiveSubmenu ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: hasActiveSubmenu ? const Color(0xFFFFD700) : const Color(0xFFE0E0E0),
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: hasActiveSubmenu ? Colors.white : const Color(0xFFE0E0E0),
                        fontSize: 14,
                        fontWeight: hasActiveSubmenu ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFFE0E0E0),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded ? Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
              ),
              child: Column(
                children: submenuItems.map((item) {
                  final isActive = widget.currentRoute == item['route'];
                  return InkWell(
                    onTap: () => context.go(item['route']!),
                    child: Container(
                      padding: const EdgeInsets.only(left: 56, right: 24, top: 12, bottom: 12),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFFFD700) : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isActive ? const Color(0xFFFFD700) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item['label']!,
                          style: TextStyle(
                            color: isActive ? Colors.black : Colors.white,
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
            : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              isCollapsed = !isCollapsed;
              if (isCollapsed) {
                expandedSubmenu = null; // Close submenus when collapsing
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isCollapsed ? Icons.chevron_right : Icons.chevron_left,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}