import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/features/auth/providers/auth_provider.dart' as auth;
import 'package:royal_tint/features/manager/providers/manager_provider.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    final authProvider = context.read<auth.AuthProvider>();
    final managerProvider = context.read<ManagerProvider>();
    
    if (authProvider.branchID != null) {
      await managerProvider.init(authProvider.branchID!);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshDashboard() async {
    final managerProvider = context.read<ManagerProvider>();
    await managerProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<auth.AuthProvider, ManagerProvider>(
      builder: (context, authProvider, managerProvider, child) {
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshDashboard,
          color: const Color(0xFFFFD700),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(authProvider),
                const SizedBox(height: 20),
                
                // Dashboard Stats
                _buildDashboardStats(managerProvider),
                const SizedBox(height: 20),
                
                // Content Grid (Appointments & Activities) - EQUAL SIZES
                _buildContentGrid(managerProvider),
                const SizedBox(height: 20),
                
                // Quick Actions
                _buildQuickActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================
  // WELCOME SECTION
  // ============================================
  
  Widget _buildWelcomeSection(auth.AuthProvider authProvider) {
    String managerName = authProvider.manager?.name ?? 'Manager';
    String branchName = authProvider.branchName ?? 'Branch';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Welcome Back, $managerName! ',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                '👋',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                BootstrapIcons.geo_alt_fill,
                color: Color(0xFFFFD700),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                branchName,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(
                      BootstrapIcons.circle_fill,
                      color: Color(0xFF4CAF50),
                      size: 8,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Here's what's happening with your business today.",
            style: TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DASHBOARD STATS
  // ============================================
  
  Widget _buildDashboardStats(ManagerProvider managerProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          // Desktop: 4 columns
          return SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    icon: BootstrapIcons.calendar_check_fill,
                    value: '${managerProvider.todayAppointments}',
                    label: "Today's Appointments",
                    badge: 'Today',
                    gradientColors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox(
                    icon: BootstrapIcons.clock_history,
                    value: '${managerProvider.pendingTasks}',
                    label: 'Pending Tasks',
                    badge: 'Pending',
                    gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox(
                    icon: BootstrapIcons.cash_coin,
                    value: 'RM ${managerProvider.monthlyRevenue.toStringAsFixed(0)}',
                    label: 'Monthly Revenue',
                    badge: 'This Month',
                    gradientColors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox(
                    icon: BootstrapIcons.people_fill,
                    value: '${managerProvider.activeStaff}',
                    label: 'Active Staff',
                    badge: 'Active',
                    gradientColors: [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
                  ),
                ),
              ],
            ),
          );
        } else if (constraints.maxWidth > 800) {
          // Tablet: 2 rows
          return Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        icon: BootstrapIcons.calendar_check_fill,
                        value: '${managerProvider.todayAppointments}',
                        label: "Today's Appointments",
                        badge: 'Today',
                        gradientColors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatBox(
                        icon: BootstrapIcons.clock_history,
                        value: '${managerProvider.pendingTasks}',
                        label: 'Pending Tasks',
                        badge: 'Pending',
                        gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        icon: BootstrapIcons.cash_coin,
                        value: 'RM ${managerProvider.monthlyRevenue.toStringAsFixed(0)}',
                        label: 'Monthly Revenue',
                        badge: 'This Month',
                        gradientColors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatBox(
                        icon: BootstrapIcons.people_fill,
                        value: '${managerProvider.activeStaff}',
                        label: 'Active Staff',
                        badge: 'Active',
                        gradientColors: [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          // Mobile: stacked
          return Column(
            children: [
              SizedBox(
                height: 100,
                child: _buildStatBox(
                  icon: BootstrapIcons.calendar_check_fill,
                  value: '${managerProvider.todayAppointments}',
                  label: "Today's Appointments",
                  badge: 'Today',
                  gradientColors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: _buildStatBox(
                  icon: BootstrapIcons.clock_history,
                  value: '${managerProvider.pendingTasks}',
                  label: 'Pending Tasks',
                  badge: 'Pending',
                  gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: _buildStatBox(
                  icon: BootstrapIcons.cash_coin,
                  value: 'RM ${managerProvider.monthlyRevenue.toStringAsFixed(0)}',
                  label: 'Monthly Revenue',
                  badge: 'This Month',
                  gradientColors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: _buildStatBox(
                  icon: BootstrapIcons.people_fill,
                  value: '${managerProvider.activeStaff}',
                  label: 'Active Staff',
                  badge: 'Active',
                  gradientColors: [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String value,
    required String label,
    required String badge,
    required List<Color> gradientColors,
  }) {
    return _HoverableCard(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFFE0E0E0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 2),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CONTENT GRID - EQUAL SIZES WITH WHITE BACKGROUND
  // ============================================
  
  Widget _buildContentGrid(ManagerProvider managerProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          // Desktop: Two columns with EQUAL sizes
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildUpcomingAppointments(managerProvider),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildRecentActivities(managerProvider),
              ),
            ],
          );
        } else {
          // Mobile/Tablet: Stack vertically
          return Column(
            children: [
              _buildUpcomingAppointments(managerProvider),
              const SizedBox(height: 20),
              _buildRecentActivities(managerProvider),
            ],
          );
        }
      },
    );
  }

  // UPCOMING APPOINTMENTS - BLACK HEADER + WHITE BODY
  Widget _buildUpcomingAppointments(ManagerProvider managerProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // BLACK HEADER with GOLD TEXT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Color(0xFF1A1A1A)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      BootstrapIcons.calendar3,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'UPCOMING APPOINTMENTS',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go('/manager/appointments'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'VIEW ALL',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          BootstrapIcons.arrow_right,
                          color: Color(0xFFFFD700),
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // WHITE BODY with BLACK-GOLD CONTENT
          Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(minHeight: 300),
            child: managerProvider.appointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          BootstrapIcons.calendar_x,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No appointments today',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: managerProvider.appointments.length > 3 
                        ? 3 
                        : managerProvider.appointments.length,
                    itemBuilder: (context, index) {
                      final apt = managerProvider.appointments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.black, Color(0xFF1A1A1A)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apt.customerName,
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        BootstrapIcons.car_front_fill,
                                        color: Color(0xFFFFD700),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          apt.vehicleDisplay,
                                          style: const TextStyle(
                                            color: Color(0xFFE0E0E0),
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        BootstrapIcons.clock,
                                        color: Color(0xFFFFD700),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        apt.appointmentTime,
                                        style: const TextStyle(
                                          color: Color(0xFFE0E0E0),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(apt.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _getStatusColor(apt.status),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                apt.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(apt.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // RECENT ACTIVITIES - BLACK HEADER + WHITE BODY
  Widget _buildRecentActivities(ManagerProvider managerProvider) {
    // Generate activities from appointments
    List<Map<String, dynamic>> activities = [];
    
    for (var apt in managerProvider.appointments.take(4)) {
      activities.add({
        'icon': BootstrapIcons.calendar_check_fill,
        'iconGradient': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
        'title': '${apt.customerName} booked an appointment',
        'subtitle': '${apt.packageName} • ${apt.vehicleDisplay}',
        'time': '10 min ago',
      });
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // BLACK HEADER with GOLD TEXT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Color(0xFF1A1A1A)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  BootstrapIcons.activity,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'RECENT ACTIVITIES',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // WHITE BODY with BLACK-GOLD CONTENT
          Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(minHeight: 300),
            child: activities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          BootstrapIcons.clock_history,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No recent activities',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length > 4 ? 4 : activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.black, Color(0xFF1A1A1A)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.25),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: activity['iconGradient'] as List<Color>,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                activity['icon'] as IconData,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity['title'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activity['subtitle'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFFE0E0E0),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              activity['time'] as String,
                              style: TextStyle(
                                color: const Color(0xFFFFD700).withOpacity(0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF4CAF50);
      case 'PENDING':
        return const Color(0xFFFFC107);
      case 'COMPLETED':
        return const Color(0xFF2196F3);
      case 'CANCELLED':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  // ============================================
  // QUICK ACTIONS - BLACK HEADER + WHITE BODY
  // ============================================

  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BLACK HEADER with GOLD TEXT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Color(0xFF1A1A1A)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: const  Row(
              children: [
                Icon(
                  BootstrapIcons.lightning_charge_fill,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // WHITE BODY with BLACK-GOLD BUTTONS
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: BootstrapIcons.calendar_plus,
                    label: 'NEW BOOKING',
                    onTap: () => context.go('/manager/appointments'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: BootstrapIcons.list_task,
                    label: 'ASSIGN TASK',
                    onTap: () => context.go('/manager/staff-tasks'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: BootstrapIcons.receipt,
                    label: 'RECORD SALE',
                    onTap: () => context.go('/manager/sales-reports'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: BootstrapIcons.box_seam,
                    label: 'MANAGE STOCK',
                    onTap: () => context.go('/manager/edit-package'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  // ignore: unused_element_parameter
  const _HoverableCard({required this.child, this.onTap});

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}