import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/admin_web/features/appointments/screens/appointment_management_screen.dart';
import 'package:royal_tint/admin_web/features/dashboard/screens/manager_dashboard_screen.dart';
import 'package:royal_tint/admin_web/features/manager_shell/widgets/manager_layout.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/screens/staff_registration_screen.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/screens/staff_tasks_screen.dart';
import 'package:royal_tint/admin_web/features/profiles/screens/profile_screen.dart';
import 'package:royal_tint/admin_web/features/auth/screens/login_screen.dart';
import 'package:royal_tint/admin_web/features/auth/screens/reset_password_screen.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_list/screens/staff_list_screen.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_list/screens/staff_schedule_screen.dart';
import 'package:royal_tint/admin_web/features/feedback/screens/feedback_management_screen.dart';
import 'package:royal_tint/admin_web/features/packages/screens/tinted_basic_info_screen.dart';
import 'package:royal_tint/admin_web/features/packages/screens/film_specification_screen.dart';
import 'package:royal_tint/admin_web/features/packages/screens/edit_package_screen.dart';
import 'package:royal_tint/admin_web/features/sales_reports/screens/sales_reports_screen.dart';

/// Admin Web router (manager portal).

class AdminWebAppRouter {
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
          return '/manager/login';
        }

        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.uri.path == '/manager/login';
        final isResetPassword = state.uri.path == '/reset-password';

        if (!isAuthenticated && !isLoggingIn && !isResetPassword) {
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
        // CUSTOM PASSWORD RESET PAGE
        // ============================================
        GoRoute(
          path: '/reset-password',
          name: 'reset-password',
          builder: (context, state) {
            // Firebase passes the oobCode via query parameters when a user clicks the link
            final oobCode = state.uri.queryParameters['oobCode'] ?? '';
            return ResetPasswordScreen(oobCode: oobCode);
          },
        ),

        // ============================================
        // MANAGER DASHBOARD
        // ============================================
        GoRoute(
          path: '/manager/dashboard',
          name: 'dashboard',
          builder: (context, state) => const ManagerLayout(
            child: ManagerDashboardScreen(),
          ),
        ),

        // ============================================
        // APPOINTMENTS
        // ============================================
        GoRoute(
          path: '/manager/appointments',
          name: 'appointments',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            return ManagerLayout(
              child: AppointmentManagementScreen(highlightAppointmentId: id),
            );
          },
        ),

        // ============================================
        // PRODUCT MANAGEMENT - TINTED BASIC INFO
        // ============================================
        GoRoute(
          path: '/manager/tinted-basic-info',
          name: 'tinted-basic-info',
          builder: (context, state) => const ManagerLayout(
            child: TintedBasicInfoScreen(),
          ),
        ),

        // ============================================
        // PRODUCT MANAGEMENT - FILM SPECIFICATION
        // ============================================
        GoRoute(
          path: '/manager/film-specification',
          name: 'film-specification',
          builder: (context, state) => const ManagerLayout(
            child: FilmSpecificationScreen(),
          ),
        ),

        // ============================================
        // PRODUCT MANAGEMENT - EDIT PACKAGE
        // ============================================
        GoRoute(
          path: '/manager/edit-package',
          name: 'edit-package',
          builder: (context, state) => const ManagerLayout(
            child: EditPackageScreen(),
          ),
        ),

        // ============================================
        // STAFF MANAGEMENT - STAFF LIST
        // ============================================
        GoRoute(
          path: '/manager/staff-list',
          name: 'staff-list',
          builder: (context, state) => const ManagerLayout(
            child: StaffListScreen(),
          ),
        ),

        // ============================================
        // STAFF MANAGEMENT - STAFF SCHEDULE
        // ============================================
        GoRoute(
          path: '/manager/staff-schedule/:id',
          name: 'staff-schedule',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return ManagerLayout(
              child: StaffScheduleScreen(staffId: id),
            );
          },
        ),

        // ============================================
        // STAFF MANAGEMENT - REGISTER NEW STAFF
        // ============================================
        GoRoute(
          path: '/manager/staff-registration',
          name: 'staff-registration',
          builder: (context, state) => const ManagerLayout(
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
            child: StaffTasksScreen(),
          ),
        ),

        // ============================================
        // SALES & REPORTS
        // ============================================
        GoRoute(
          path: '/manager/sales-reports',
          name: 'sales-reports',
          builder: (context, state) => const ManagerLayout(
            child: SalesReportsScreen(),
          ),
        ),

        // ============================================
        // CUSTOMER FEEDBACKS
        // ============================================
        GoRoute(
          path: '/manager/feedback',
          name: 'feedback',
          builder: (context, state) => const ManagerLayout(
            child: FeedbackManagementScreen(),
          ),
        ),

        // ============================================
        // MY PROFILE
        // ============================================
        GoRoute(
          path: '/manager/profile',
          name: 'profile',
          builder: (context, state) => const ManagerLayout(
            child: ProfileScreen(),
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