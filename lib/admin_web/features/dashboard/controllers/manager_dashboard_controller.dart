import 'package:flutter/foundation.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/admin_web/features/dashboard/providers/manager_provider.dart';
import 'package:royal_tint/admin_web/features/dashboard/services/manager_dashboard_stats_service.dart';
import 'package:royal_tint/admin_web/features/dashboard/services/staff_query_service.dart';
import 'package:royal_tint/admin_web/features/dashboard/utils/date_utils.dart';

class ManagerDashboardController {
  ManagerDashboardController({
    AppointmentService? appointmentService,
    ManagerDashboardStatsService? statsService,
    StaffQueryService? staffQueryService,
  })  : _appointmentService = appointmentService ?? AppointmentService(),
        _statsService = statsService ?? ManagerDashboardStatsService(),
        _staffQueryService = staffQueryService ?? StaffQueryService();

  final AppointmentService _appointmentService;
  final ManagerDashboardStatsService _statsService;
  final StaffQueryService _staffQueryService;

  Future<void> init(ManagerProvider provider, String branchID) async {
    provider.setBranch(branchID);
    await load(provider);
  }

  Future<void> refresh(ManagerProvider provider) async {
    if (provider.branchID == null) return;
    await load(provider);
  }

  Future<void> load(ManagerProvider provider) async {
    final branchID = provider.branchID;
    if (branchID == null) return;

    try {
      provider.setLoading(true);
      provider.setError(null);

      final todayYmd = ymd(DateTime.now());

      // ✅ TODAY ONLY (uses your existing service filter pending+confirmed)
      final todayList= await _appointmentService.getAppointmentsByDate(
        branchID: branchID,
        date: todayYmd,
      );

      provider.setAppointments(todayList);

      final todayTotalCount = await _statsService.getTodayAppointmentsCount(
        branchID: branchID,
      );

      final monthlyRevenue = await _statsService.getMonthlyRevenue(branchID: branchID);
      final activeStaff = await _statsService.getActiveStaffCount(branchID: branchID);

      provider.setStats(
        todayAppointments: todayTotalCount,
        monthlyRevenue: monthlyRevenue,
        activeStaff: activeStaff,
      );

      provider.setLoading(false);
    } catch (e) {
      provider.setLoading(false);
      provider.setError('Failed to load dashboard: $e');
      debugPrint('🔴 Dashboard load ERROR: $e');
    }
  }
}