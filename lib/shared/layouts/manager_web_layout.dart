import 'package:flutter/material.dart';
import 'package:royal_tint/features/manager/widgets/manager_navbar.dart';
import 'package:royal_tint/features/manager/widgets/manager_sidebar.dart';
import 'package:royal_tint/features/manager/widgets/manager_footer.dart';

class ManagerWebLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  
  const ManagerWebLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          ManagerSidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                const ManagerNavbar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
                const ManagerFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}