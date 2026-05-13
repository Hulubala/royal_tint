import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/mobile_app/features/staff/main/screens/staff_home_screen.dart';
import 'package:royal_tint/mobile_app/features/staff/tasks/screens/staff_task_list_screen.dart';
import 'package:royal_tint/mobile_app/features/staff/main/screens/staff_profile_screen.dart';

class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StaffHomeScreen(),
    const StaffTaskListScreen(),
    const StaffProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.black,
          selectedItemColor: const Color(0xFFFFD700),
          unselectedItemColor: const Color(0xFFFFD700).withOpacity(0.4),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.house),
              activeIcon: Icon(BootstrapIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.clipboard_check),
              activeIcon: Icon(BootstrapIcons.clipboard_check_fill),
              label: 'Assigned',
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.person_circle),
              activeIcon: Icon(BootstrapIcons.person_circle),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
