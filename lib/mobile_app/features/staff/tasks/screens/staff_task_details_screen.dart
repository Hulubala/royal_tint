import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/data/repositories/staff_repository.dart';
import 'package:royal_tint/data/repositories/staff_task_repository.dart';
import 'package:royal_tint/mobile_app/features/staff/tasks/models/staff_task_model.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_header.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';

class StaffTaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const StaffTaskDetailsScreen({super.key, required this.taskId});

  @override
  State<StaffTaskDetailsScreen> createState() => _StaffTaskDetailsScreenState();
}

class _StaffTaskDetailsScreenState extends State<StaffTaskDetailsScreen> {
  final _taskRepo  = StaffTaskRepository();
  final _staffRepo = StaffRepository();

  bool _loading = false;

  // ── Colours ──────────────────────────────────────────────────────────────────
  static const _bg      = Colors.white;
  static const _surface = Colors.black;
  static const _gold    = Color(0xFFFFD700);

  // ── Darkness opacity mapping for glass swatch ─────────────────────────────
  double _darknessOpacity(String code) {
    final c = code.toUpperCase();
    if (c.endsWith('05')) return 0.88;
    if (c.endsWith('20')) return 0.72;
    if (c.endsWith('30')) return 0.60;
    if (c.endsWith('35')) return 0.55;
    if (c.endsWith('50')) return 0.40;
    if (c.endsWith('70')) return 0.22;
    return 0.50;
  }

  Future<void> _handleStartTask(StaffTaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Start Task?',
        message:
            'This will change the task and appointment status to In Progress.',
        confirmLabel: 'Start',
        confirmColor: const Color(0xFF2196F3),
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await _taskRepo.startTask(task.id, task.appointmentID);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task started! Status changed to In Progress.'),
          backgroundColor: Color(0xFF2196F3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleCompleteTask(StaffTaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: 'Complete Task?',
        message: 'This will mark the task and appointment as Completed.',
        confirmLabel: 'Complete',
        confirmColor: Color(0xFF4CAF50),
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final staff = await _staffRepo.getCurrentStaff();
      await _taskRepo.completeTask(task.id, task.appointmentID, staff.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task completed! Great work.'),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          StaffHeader(
            title: 'Task Details',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: StreamBuilder<StaffTaskModel?>(
              stream: _taskRepo.watchTaskById(widget.taskId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _gold));
                }

                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Error loading task:\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }

                final task = snap.data;

                if (task == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt_rounded, color: Colors.grey[600], size: 52),
                        const SizedBox(height: 14),
                        Text(
                          'Task not found.',
                          style: TextStyle(color: Colors.grey[500], fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded, color: _gold),
                          label: const Text('Go Back',
                              style: TextStyle(color: _gold)),
                        ),
                      ],
                    ),
                  );
                }

                return _buildBody(task);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBody(StaffTaskModel task) {
    final statusColor = _statusColor(task.status);
    final statusLabel = _statusLabel(task.status);

    final sections = task.mirrorSection
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final List<String> rawDarkness = task.darkness.split(',').map((d) => d.trim()).toList();
    
    // Map of label -> darkness code
    final Map<String, String> sectionData = {};
    for (int i = 0; i < sections.length; i++) {
      final label = sections[i];
      final key = TintSections.keyByLabel[label] ?? label.toLowerCase();
      final val = i < rawDarkness.length ? rawDarkness[i] : '';
      
      if (val.isEmpty || val == '—') {
        sectionData[label] = '—';
      } else {
        sectionData[label] = mapVLTtoCode(val, task.packageName, sectionKey: key);
      }
    }

    // Sort sections based on preferred order: Front Windscreen, Front Side Windows, Rear Passenger, Rear Windscreen
    final orderedLabels = [
      'Front Windscreen',
      'Front Side Windows',
      'Rear Passenger',
      'Rear Windscreen',
    ];
    
    final sortedSections = orderedLabels.where((l) => sectionData.containsKey(l)).toList();
    // Add any remaining sections that were not in orderedLabels
    for (final s in sections) {
      if (!orderedLabels.contains(s)) sortedSections.add(s);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status banner (Boxed) ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _gold.withOpacity(0.8), width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_statusIcon(task.status), color: statusColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      statusLabel.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _statusHint(task.status),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Vehicle info card (Boxed) ─────────────────────────────────────
          _SectionCard(
            icon: Icons.directions_car_rounded,
            title: 'Vehicle Details',
            child: Column(
              children: [
                _DetailRow(label: 'Brand',    value: task.carBrand),
                _DetailRow(label: 'Model',    value: task.carModel),
                _DetailRow(label: 'Plate',    value: task.plateNumber),
                _DetailRow(label: 'Customer', value: task.customerName),
                _DetailRow(label: 'Package',  value: task.packageName),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Mirror sections (Boxed) ───────────────────────────────────────
          _SectionCard(
            icon: Icons.grid_view_rounded,
            title: 'Mirror Sections',
            child: sortedSections.isEmpty
                ? Text('No sections assigned', style: TextStyle(color: Colors.grey[600], fontSize: 14))
                : Column(
                    children: sortedSections.map((section) {
                      final darkness = sectionData[section] ?? '—';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _gold.withOpacity(0.15), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _gold.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.layers_rounded, color: _gold, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section,
                                    style: const TextStyle(color: _gold, fontSize: 15, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Outfit'),
                                      children: [
                                        const TextSpan(
                                          text: 'Darkness: ',
                                          style: TextStyle(color: _gold, fontWeight: FontWeight.w900),
                                        ),
                                        TextSpan(text: darkness),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 32),

          // ── Action buttons ────────────────────────────────────────────────
          if (task.isPending)
            _ActionButton(
              label: 'START TASK',
              icon: Icons.play_arrow_rounded,
              color: const Color(0xFF2196F3),
              loading: _loading,
              onPressed: () => _handleStartTask(task),
            ),

          if (task.isInProgress)
            _ActionButton(
              label: 'COMPLETE TASK',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF4CAF50),
              loading: _loading,
              onPressed: () => _handleCompleteTask(task),
            ),

          if (task.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5), width: 2),
              ),
              child: const Column(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF4CAF50), size: 32),
                  SizedBox(height: 12),
                  Text(
                    'TASK COMPLETED',
                    style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':     return const Color(0xFFFFB300);
      case 'IN_PROGRESS': 
      case 'IN-PROGRESS': return const Color(0xFF2196F3);
      case 'COMPLETED':   return const Color(0xFF4CAF50);
      default:            return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':     return 'Pending';
      case 'IN_PROGRESS': 
      case 'IN-PROGRESS': return 'In Progress';
      case 'COMPLETED':   return 'Completed';
      default:            return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':     return Icons.hourglass_empty_rounded;
      case 'IN_PROGRESS': return Icons.autorenew_rounded;
      case 'COMPLETED':   return Icons.check_circle_rounded;
      default:            return Icons.help_outline_rounded;
    }
  }

  String _statusHint(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':     return 'Tap Start Task to begin';
      case 'IN_PROGRESS': return 'Tap Complete when done';
      case 'COMPLETED':   return 'All done!';
      default:            return '';
    }
  }
}

// ── Reusable section card ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  static const _gold    = Color(0xFFFFD700);
  static const _card    = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _gold, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF333333), height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Single info row ───────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Big action button ─────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
        ),
        icon: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Icon(icon, size: 24),
        label: Text(
          loading ? 'Please wait...' : label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

// ── Confirmation dialog ───────────────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w900),
      ),
      content: Text(
        message,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}
