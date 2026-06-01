import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class FeedbackStatisticsSection extends StatelessWidget {
  final int totalCount;
  final int servicesCount;
  final int productCount;

  const FeedbackStatisticsSection({
    super.key,
    required this.totalCount,
    required this.servicesCount,
    required this.productCount,
  });

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    Widget? subtitleWidget,
  }) {
    const gold = Color(0xFFFFD700);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: gold, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: gold,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitleWidget != null) ...[
                const SizedBox(height: 4),
                subtitleWidget,
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final isWide = cardConstraints.maxWidth > 900;
        if (isWide) {
          return SizedBox(
            height: 160, 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Feedbacks',
                    value: totalCount.toString(),
                    icon: BootstrapIcons.chat_right_quote_fill,
                    subtitleWidget: const Text(
                      'All time feedbacks',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    title: 'Services',
                    value: servicesCount.toString(),
                    icon: BootstrapIcons.gear_fill,
                    subtitleWidget: const Text(
                      'Service feedback',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    title: 'Product Quality',
                    value: productCount.toString(),
                    icon: BootstrapIcons.box_seam_fill,
                    subtitleWidget: const Text(
                      'Product feedback',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              _buildStatCard(
                title: 'Total Feedbacks',
                value: totalCount.toString(),
                icon: BootstrapIcons.chat_right_quote_fill,
                subtitleWidget: const Text(
                  'All time feedbacks',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'Services',
                value: servicesCount.toString(),
                icon: BootstrapIcons.gear_fill,
                subtitleWidget: const Text(
                  'Service feedback',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'Product Quality',
                value: productCount.toString(),
                icon: BootstrapIcons.box_seam_fill,
                subtitleWidget: const Text(
                  'Product feedback',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
