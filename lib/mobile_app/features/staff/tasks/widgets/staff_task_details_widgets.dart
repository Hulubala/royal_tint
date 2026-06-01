import 'package:flutter/material.dart';

// ── Shared UI Constants ───────────────────────────────────────────────────────
const _gold = Color(0xFFFFD700);
const _surface = Colors.black;
const _card = Colors.black;

// ── Status banner (Boxed) ─────────────────────────────────────────
class TaskStatusBanner extends StatelessWidget {
  final String status;
  
  const TaskStatusBanner({super.key, required this.status});

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

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_statusIcon(status), color: statusColor, size: 24),
              const SizedBox(width: 12),
              Text(
                statusLabel.toUpperCase(),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _statusHint(status),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Reusable section card ─────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
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
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.w900),
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
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
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
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
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
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  const ConfirmDialog({
    super.key,
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
        side: const BorderSide(color: _gold, width: 2),
      ),
      title: Text(
        title,
        style: const TextStyle(color: _gold, fontWeight: FontWeight.w900),
      ),
      content: Text(
        message,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, height: 1.5),
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

// ── Task Completed Banner ───────────────────────────────────────────────────────
class TaskCompletedBanner extends StatelessWidget {
  const TaskCompletedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5), width: 2),
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
    );
  }
}

// ── Mirror Sections Component ───────────────────────────────────────────────────────
class MirrorSectionsCard extends StatelessWidget {
  final List<String> sortedSections;
  final Map<String, String> sectionData;

  const MirrorSectionsCard({
    super.key,
    required this.sortedSections,
    required this.sectionData,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
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
                    border: Border.all(color: _gold.withValues(alpha: 0.15), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.05),
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
    );
  }
}
