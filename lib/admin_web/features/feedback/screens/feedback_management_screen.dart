import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/admin_web/features/feedback/providers/feedback_provider.dart';
import 'package:royal_tint/admin_web/features/feedback/models/feedback_item.dart';
import 'package:royal_tint/admin_web/features/feedback/widgets/feedback_statistics_section.dart';
import 'package:royal_tint/admin_web/features/feedback/widgets/feedback_filter_bar.dart';
import 'package:royal_tint/admin_web/features/feedback/widgets/feedback_grid.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() => _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _initialized = false;
  String _selectedCategory = 'all';
  String _dateFilter = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    if (!_initialized && authProvider.isAuthenticated) {
      final branchID = authProvider.branchID;
      context.read<FeedbackProvider>().loadFeedback(branchID);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(FeedbackItem item) async {
    const gold = Color(0xFFFFD700);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[950],
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: gold, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(BootstrapIcons.trash, color: Colors.red, size: 22),
            SizedBox(width: 10),
            Text(
              'Delete Feedback',
              style: TextStyle(color: gold, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete this feedback from ${item.customerName}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      await context.read<FeedbackProvider>().removeFeedback(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback deleted successfully.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    final p = context.watch<FeedbackProvider>();
    final allFeedbacks = p.feedbacks;

    final filteredFeedbacks = allFeedbacks.where((f) {
      final search = _searchController.text.trim().toLowerCase();
      final matchesSearch = search.isEmpty ||
          f.customerName.toLowerCase().contains(search) ||
          f.customerEmail.toLowerCase().contains(search) ||
          f.customerPhone.toLowerCase().contains(search) ||
          (f.carPlate?.toLowerCase().contains(search) ?? false) ||
          f.comment.toLowerCase().contains(search);

      final matchesCategory = _selectedCategory == 'all' || f.category.toLowerCase() == _selectedCategory.toLowerCase();

      bool matchesDate = true;
      if (_dateFilter != 'all' && f.createdAt != null) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        
        if (_dateFilter == 'today') {
           matchesDate = f.createdAt!.isAfter(todayStart) || f.createdAt!.isAtSameMomentAs(todayStart);
        } else if (_dateFilter == 'this_week') {
           matchesDate = f.createdAt!.isAfter(now.subtract(const Duration(days: 7)));
        } else if (_dateFilter == 'this_month') {
           matchesDate = f.createdAt!.isAfter(now.subtract(const Duration(days: 30)));
        }
      }
      return matchesSearch && matchesCategory && matchesDate;
    }).toList();

    final totalCount = allFeedbacks.length;
    final servicesCount = allFeedbacks.where((f) => f.category.toLowerCase() == 'services').length;
    final productCount = allFeedbacks.where((f) => f.category.toLowerCase() == 'product quality').length;

    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner (Black & Gold)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold, width: 2),
              ),
              child: const Row(
                children: [
                  Icon(BootstrapIcons.chat_right_text_fill, color: gold, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Customer Feedbacks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: gold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Statistics Banner
            FeedbackStatisticsSection(
              totalCount: totalCount,
              servicesCount: servicesCount,
              productCount: productCount,
            ),
            const SizedBox(height: 32),

            // Filter bar banner
            FeedbackFilterBar(
              searchController: _searchController,
              selectedCategory: _selectedCategory,
              dateFilter: _dateFilter,
              onSearchChanged: (_) => setState(() {}),
              onCategoryChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
              onDateFilterChanged: (val) {
                if (val != null) setState(() => _dateFilter = val);
              },
            ),
            const SizedBox(height: 24),

            // Feedback List / Grid
            FeedbackGrid(
              feedbacks: filteredFeedbacks,
              isLoading: p.isLoading,
              onDelete: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }
}