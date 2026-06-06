import 'package:go_router/go_router.dart';
import 'package:royal_tint/mobile_app/features/common/auth/screens/boot_screen.dart';
import 'package:royal_tint/mobile_app/features/common/auth/screens/role_selection_screen.dart';
import 'package:royal_tint/mobile_app/features/customer/auth/screens/customer_login_screen.dart';
import 'package:royal_tint/mobile_app/features/customer/auth/screens/register_screen.dart';
import 'package:royal_tint/mobile_app/features/customer/main/screens/customer_main_screen.dart';
import 'package:royal_tint/mobile_app/features/staff/auth/screens/staff_login_screen.dart';
import 'package:royal_tint/mobile_app/features/staff/main/screens/staff_main_screen.dart';
import 'package:royal_tint/mobile_app/features/staff/tasks/screens/staff_task_details_screen.dart';

class MobileAppRouter {
  static GoRouter router() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const BootScreen()),
        GoRoute(path: '/role', builder: (_, __) => const RoleSelectionScreen()),

        GoRoute(path: '/customer/login', builder: (_, __) => const CustomerLoginScreen()),
        GoRoute(path: '/customer/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/customer/home', builder: (_, __) => const CustomerMainScreen()),

        GoRoute(path: '/staff/login', builder: (_, __) => const StaffLoginScreen()),
        GoRoute(path: '/staff/home', builder: (_, __) => const StaffMainScreen()),
        GoRoute(
          path: '/staff/tasks/:taskId',
          builder: (_, state) => StaffTaskDetailsScreen(
            taskId: state.pathParameters['taskId'] ?? '',
          ),
        ),
      ],
    );
  }
}
