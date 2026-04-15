import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'manager_sidebar.dart';
import 'manager_navbar.dart';
import 'manager_footer.dart';

class ManagerLayout extends StatelessWidget {
  final Widget child;

  const ManagerLayout({
    super.key,
    required this.child,
  });

 String _resolveCurrentRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final noQuery = location.split('?').first;
    return noQuery;
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _resolveCurrentRoute(context);
    
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
                    child: Column(
                      children: [
                        child,
                        const ManagerFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}