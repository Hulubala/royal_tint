import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart' as auth;

import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/providers/staff_tasks_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/widgets/staff_tasks_header_panel.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/widgets/assign_task_panel.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/widgets/active_tasks_panel.dart';

class StaffTasksScreen extends StatefulWidget {
  const StaffTasksScreen({super.key});

  @override
  State<StaffTasksScreen> createState() => _StaffTasksScreenState();
}

class _StaffTasksScreenState extends State<StaffTasksScreen> {
  bool _loaded = false;

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<auth.AuthProvider>();
    final branchID = authProvider.branchID;
    final uid = authProvider.uid;

    final p = context.watch<StaffTasksProvider>();

    // Load when auth is ready
    if (!_loaded && branchID != null && uid != null) {
      _loaded = true;
      Future.microtask(() => context.read<StaffTasksProvider>().load(branchID: branchID));
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StaffTasksHeaderPanel(),
              const SizedBox(height: 18),

              if (branchID == null || uid == null)
                _errorBox('Please log in as manager to use Staff Tasks.')
              else if (p.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else if (p.error != null)
                _errorBox(p.error!, onRetry: () {
                  context.read<StaffTasksProvider>().load(branchID: branchID);
                })
              else ...[
                AssignTaskPanel(
                  branchID: branchID,
                  managerUid: uid,
                  onSuccess: (msg) => _snack(msg),
                  onError: (msg) => _snack(msg, isError: true),
                ),
                const SizedBox(height: 18),
                const ActiveTasksPanel(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBox(String msg, {VoidCallback? onRetry}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Expanded(child: Text(msg)),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ]
        ],
      ),
    );
  }
}