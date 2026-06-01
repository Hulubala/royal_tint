import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/admin_web/features/feedback/models/feedback_item.dart';

class FeedbackGrid extends StatelessWidget {
  final List<FeedbackItem> feedbacks;
  final bool isLoading;
  final Function(FeedbackItem) onDelete;

  const FeedbackGrid({
    super.key,
    required this.feedbacks,
    required this.isLoading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(color: gold)),
      );
    }

    if (feedbacks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(BootstrapIcons.chat_right_text, color: gold.withValues(alpha: 0.3), size: 64),
              const SizedBox(height: 16),
              const Text(
                'No Customer Feedbacks Found',
                style: TextStyle(
                  color: gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are no customer feedback documents matching your search criteria.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 2 : 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 200,
          ),
          itemCount: feedbacks.length,
          itemBuilder: (context, idx) {
            final item = feedbacks[idx];
            return _FeedbackCard(item: item, onDelete: onDelete);
          },
        );
      },
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackItem item;
  final Function(FeedbackItem) onDelete;

  const _FeedbackCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    final dateStr = item.createdAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(item.createdAt!)
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: gold,
                radius: 18,
                child: Text(
                  item.customerName.isNotEmpty ? item.customerName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final hasPhone = item.customerPhone.isNotEmpty && item.customerPhone != 'N/A';
                        final hasPlate = item.carPlate != null && item.carPlate!.isNotEmpty;
                        
                        final parts = <String>[];
                        if (hasPhone) parts.add(item.customerPhone);
                        parts.add(item.customerEmail);
                        if (hasPlate) parts.add(item.carPlate!.toUpperCase());
                        
                        return Text(
                          parts.join(' • '),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
              // Category badge
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onDelete(item),
                icon: const Icon(BootstrapIcons.trash, color: Colors.red, size: 16),
                tooltip: 'Delete Feedback',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0C),
                borderRadius: BorderRadius.circular(6),
                border: Border(
                  left: BorderSide(color: gold.withValues(alpha: 0.7), width: 3),
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  item.comment.isNotEmpty ? '"${item.comment}"' : '"No written comment provided."',
                  style: TextStyle(
                    color: item.comment.isNotEmpty ? Colors.white70 : Colors.white38,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
