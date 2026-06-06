import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class FeedbackStatisticsSection extends StatelessWidget {
  final int totalCount;
  final int servicesCount;
  final int productCount;
  final String dateSuffix;
  final VoidCallback onTotalTap;
  final VoidCallback onServicesTap;
  final VoidCallback onProductTap;

  const FeedbackStatisticsSection({
    super.key,
    required this.totalCount,
    required this.servicesCount,
    required this.productCount,
    required this.dateSuffix,
    required this.onTotalTap,
    required this.onServicesTap,
    required this.onProductTap,
  });

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    Widget? subtitleWidget,
    VoidCallback? onTap,
    Key? key,
  }) {
    const gold = Color(0xFFFFD700);
    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suffix = dateSuffix.isEmpty ? '' : ' ($dateSuffix)';

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final totalCard = _buildStatCard(
          key: const ValueKey('total_card'),
          title: 'Total Feedbacks$suffix',
          value: totalCount.toString(),
          icon: BootstrapIcons.chat_right_quote_fill,
          onTap: onTotalTap,
          subtitleWidget: const Row(
            children: [
              Icon(BootstrapIcons.hand_index_thumb, color: Colors.white54, size: 12),
              SizedBox(width: 4),
              Text('Click to view feedback', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        );

        final servicesCard = _buildStatCard(
          key: const ValueKey('services_card'),
          title: 'Services$suffix',
          value: servicesCount.toString(),
          icon: BootstrapIcons.gear_fill,
          onTap: onServicesTap,
          subtitleWidget: const Row(
            children: [
              Icon(BootstrapIcons.hand_index_thumb, color: Colors.white54, size: 12),
              SizedBox(width: 4),
              Text('Click to view feedback', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        );

        final productCard = _buildStatCard(
          key: const ValueKey('product_card'),
          title: 'Product Quality$suffix',
          value: productCount.toString(),
          icon: BootstrapIcons.box_seam_fill,
          onTap: onProductTap,
          subtitleWidget: const Row(
            children: [
              Icon(BootstrapIcons.hand_index_thumb, color: Colors.white54, size: 12),
              SizedBox(width: 4),
              Text('Click to view feedback', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        );

        final isWide = cardConstraints.maxWidth > 900;
        if (isWide) {
          return SizedBox(
            height: 160, 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: totalCard),
                const SizedBox(width: 20),
                Expanded(child: servicesCard),
                const SizedBox(width: 20),
                Expanded(child: productCard),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              totalCard,
              const SizedBox(height: 16),
              servicesCard,
              const SizedBox(height: 16),
              productCard,
            ],
          );
        }
      },
    );
  }
}
