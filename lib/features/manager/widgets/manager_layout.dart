import 'package:flutter/material.dart';
import 'manager_sidebar.dart';
import 'manager_navbar.dart';
import 'manager_footer.dart';

class ManagerLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const ManagerLayout({
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
          // Sidebar
          ManagerSidebar(currentRoute: currentRoute),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Navbar (Fixed)
                const ManagerNavbar(),
                
                // Page Content + Footer (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Page Content
                        child,
                        
                        // Footer (appears at bottom after scrolling)
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