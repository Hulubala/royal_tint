import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/customer_header.dart';
import 'package:royal_tint/mobile_app/features/customer/packages/widgets/catalog_basic_info_tab.dart';
import 'package:royal_tint/mobile_app/features/customer/packages/widgets/catalog_specifications_tab.dart';
import 'package:royal_tint/mobile_app/features/customer/packages/widgets/catalog_packages_tab.dart';

class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({super.key});

  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _bg = Colors.white;
  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          const CustomerHeader(title: 'Tint Info'),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: TabBar(
                controller: _tabController,
                indicatorColor: _gold,
                indicatorWeight: 3,
                labelColor: _gold,
                unselectedLabelColor: _gold.withValues(alpha: 0.4),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                tabs: const [
                  Tab(
                    icon: Icon(BootstrapIcons.info_circle_fill, size: 16),
                    text: 'Basic Info',
                  ),
                  Tab(
                    icon: Icon(BootstrapIcons.sliders, size: 16),
                    text: 'Film Specs',
                  ),
                  Tab(
                    icon: Icon(BootstrapIcons.box_seam_fill, size: 16),
                    text: 'Packages',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CatalogBasicInfoTab(),
                CatalogSpecificationsTab(),
                CatalogPackagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
