import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/features/manager/screens/staff_registration_screen.dart';
import 'package:royal_tint/features/manager/widgets/manager_layout.dart';
import 'package:royal_tint/features/manager/screens/manager_dashboard_screen.dart';
import 'package:royal_tint/features/manager/screens/appointment_management_screen.dart';
import 'package:royal_tint/features/manager/screens/manager_login_screen.dart';
import 'package:royal_tint/features/auth/providers/auth_provider.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/manager/login',
      refreshListenable: authProvider,
      
      // ============================================
      // ROUTE PROTECTION - REDIRECT LOGIC
      // ============================================
      redirect: (BuildContext context, GoRouterState state) {
        // Remove setup route access after initial setup
        if (state.uri.toString() == '/setup') {
          return '/manager/login'; // Redirect to login
        }
        
        // Check authentication from AuthProvider (NOT AuthState)
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.uri.toString() == '/manager/login';
        
        if (!isAuthenticated && !isLoggingIn) {
          return '/manager/login';
        }
        
        if (isAuthenticated && isLoggingIn) {
          return '/manager/dashboard';
        }
        
        return null;
      },
      
      routes: [
        // ============================================
        // MANAGER LOGIN
        // ============================================
        GoRoute(
          path: '/manager/login',
          name: 'manager-login',
          builder: (context, state) => const ManagerLoginScreen(),
        ),
        
        // ============================================
        // MANAGER DASHBOARD
        // ============================================
        GoRoute(
          path: '/manager/dashboard',
          name: 'dashboard',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/dashboard',
            child: ManagerDashboardScreen(),
          ),
        ),
        
        // ============================================
        // APPOINTMENTS
        // ============================================
        GoRoute(
          path: '/manager/appointments',
          name: 'appointments',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/appointments',
            child: AppointmentManagementScreen(),
          ),
        ),
        
        // ============================================
        // PRODUCT MANAGEMENT - PRODUCT CODE
        // ============================================
        GoRoute(
          path: '/manager/product-code',
          name: 'product-code',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/product-code',
            child: _PlaceholderPage(
              title: 'Product Code',
              icon: BootstrapIcons.qr_code,
            ),
          ),
        ),
        
        // ============================================
        // PRODUCT MANAGEMENT - STOCK CUT FILM
        // ============================================
        GoRoute(
          path: '/manager/stock-cut-film',
          name: 'stock-cut-film',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/stock-cut-film',
            child: _PlaceholderPage(
              title: 'Stock Cut Film',
              icon: BootstrapIcons.box_seam,
            ),
          ),
        ),
        
        // ============================================
        // PRODUCT MANAGEMENT - EDIT PACKAGE
        // ============================================
        GoRoute(
          path: '/manager/edit-package',
          name: 'edit-package',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/edit-package',
            child: _PlaceholderPage(
              title: 'Edit Package',
              icon: BootstrapIcons.pencil_square,
            ),
          ),
        ),
        
        // ============================================
        // STAFF MANAGEMENT - REGISTER NEW STAFF
        // ============================================
        GoRoute(
          path: '/manager/staff-registration',
          name: 'staff-registration',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/staff-registration',
            child: StaffRegistrationScreen(),
            ),
          ),

        // ============================================
        // STAFF MANAGEMENT - STAFF TASKS
        // ============================================
        GoRoute(
          path: '/manager/staff-tasks',
          name: 'staff-tasks',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/staff-tasks',
            child: _PlaceholderPage(
              title: 'Staff Tasks',
              icon: BootstrapIcons.list_task,
            ),
          ),
        ),
        
        // ============================================
        // SERVICE HISTORY
        // ============================================
        GoRoute(
          path: '/manager/service-history',
          name: 'service-history',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/service-history',
            child: _PlaceholderPage(
              title: 'Service History',
              icon: BootstrapIcons.clock_history,
            ),
          ),
        ),
        
        // ============================================
        // SALES & REPORTS
        // ============================================
        GoRoute(
          path: '/manager/sales-reports',
          name: 'sales-reports',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/sales-reports',
            child: _PlaceholderPage(
              title: 'Sales & Reports',
              icon: BootstrapIcons.bar_chart_fill,
            ),
          ),
        ),
        
        // ============================================
        // CUSTOMER FEEDBACKS
        // ============================================
        GoRoute(
          path: '/manager/feedback',
          name: 'feedback',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/feedback',
            child: _PlaceholderPage(
              title: 'Customer Feedbacks',
              icon: BootstrapIcons.star_fill,
            ),
          ),
        ),
        
        // ============================================
        // MY PROFILE
        // ============================================
        GoRoute(
          path: '/manager/profile',
          name: 'profile',
          builder: (context, state) => const ManagerLayout(
            currentRoute: '/manager/profile',
            child: _PlaceholderPage(
              title: 'My Profile',
              icon: BootstrapIcons.person_circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// PLACEHOLDER PAGE WIDGET
// ============================================

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(48),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
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
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 3),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFFD700),
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              const Text(
                'Coming Soon',
                style: TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Loading indicator with Bootstrap Icons
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFD700),
                      ),
                    ),
                  ),
                  Icon(
                    BootstrapIcons.hourglass_split,
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}