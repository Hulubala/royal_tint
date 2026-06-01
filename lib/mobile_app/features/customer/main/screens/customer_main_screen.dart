import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/mobile_app/features/customer/main/screens/customer_home_screen.dart';
import 'package:royal_tint/mobile_app/features/customer/packages/screens/customer_catalog_screen.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/screens/customer_booking_screen.dart';
import 'package:royal_tint/mobile_app/features/customer/feedback/screens/customer_feedback_screen.dart';
import 'package:royal_tint/mobile_app/features/customer/main/screens/customer_profile_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  static void changeTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_CustomerMainScreenState>();
    if (state != null) {
      state.setTab(index);
    }
  }

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  void setTab(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _screens = const [
    CustomerHomeScreen(),
    CustomerCatalogScreen(),
    CustomerBookingScreen(),
    CustomerFeedbackScreen(),
    CustomerProfileScreen(),
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
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.house),
              activeIcon: Icon(BootstrapIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.info_circle),
              activeIcon: Icon(BootstrapIcons.info_circle_fill),
              label: 'Tint Info',
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.calendar_plus),
              activeIcon: Icon(BootstrapIcons.calendar_plus_fill),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.chat_right_quote),
              activeIcon: Icon(BootstrapIcons.chat_right_quote_fill),
              label: 'Feedback',
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
