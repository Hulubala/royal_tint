import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart' as auth;
import 'package:royal_tint/admin_web/features/dashboard/controllers/manager_dashboard_controller.dart';
import 'package:royal_tint/admin_web/features/dashboard/providers/manager_provider.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/content_grid.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/dashboard_stats.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/quick_actions.dart';
import 'package:royal_tint/admin_web/features/dashboard/widgets/welcome_section.dart';
import 'package:royal_tint/admin_web/features/manager_shell/providers/manager_shell_provider.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final _controller = ManagerDashboardController();
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _init();
    });
  }

  Future<void> _init() async {
    final authProvider = context.read<auth.AuthProvider>();
    final managerProvider = context.read<ManagerProvider>();

    final branchID = authProvider.branchID;
    if (branchID != null) {
      await _controller.init(managerProvider, branchID);
      final count = managerProvider.todayAppointments;

      // ✅ update navbar badge
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.read<ManagerShellProvider>().setUnreadNotifications(count);
      });
    }
  }

  Future<void> _refresh() async {
    final managerProvider = context.read<ManagerProvider>();
    await _controller.refresh(managerProvider);
    final count = managerProvider.todayAppointments;

    // ✅ keep navbar badge updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<ManagerShellProvider>().setUnreadNotifications(count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<auth.AuthProvider, ManagerProvider>(
      builder: (context, authProvider, managerProvider, child) {
        if (managerProvider.isLoading && managerProvider.appointments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFFFFD700),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeSection(authProvider: authProvider),
                const SizedBox(height: 20),
                DashboardStats(managerProvider: managerProvider),
                const SizedBox(height: 20),
                ContentGrid(managerProvider: managerProvider),
                const SizedBox(height: 20),
                const QuickActions(),
              ],
            ),
          ),
        );
      },
    );
  }
}