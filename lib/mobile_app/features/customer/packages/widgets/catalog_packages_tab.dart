import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/data/services/package_service.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';

class CatalogPackagesTab extends StatelessWidget {
  const CatalogPackagesTab({super.key});

  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final PackageService packageService = PackageService();
    
    return FutureBuilder<List<TintPackageModel>>(
      future: packageService.getAllPackages(),
      builder: (context, pkgSnapshot) {
        if (pkgSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _gold));
        }
        final pkgs = pkgSnapshot.data ?? [];
        if (pkgs.isEmpty) {
          return const Center(
            child: Text(
              'No packages available.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pkgs.length,
          itemBuilder: (context, index) {
            final pkg = pkgs[index];
            const IconData icon = BootstrapIcons.box_seam;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _showPackageDetailsDialog(context, pkg),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(icon, color: _gold, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                pkg.packageName.toUpperCase(),
                                style: const TextStyle(
                                  color: _gold,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _gold, width: 1),
                            ),
                            child: Text(
                              'RM ${pkg.getPriceForVehicle('sedan').toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pkg.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 12),
                      _buildFeatureRow('Darkness (VLT-%)', _formatVltRange(pkg.darknessOptions)),
                      _buildFeatureRow('UV Rejection (UVR-%)', _formatPercentageOnly(pkg.uvRejection)),
                      _buildFeatureRow('Heat Rejection (IRR-%)', _formatPercentageOnly(pkg.heatRejection)),
                      _buildFeatureRow('Warranty (Years)', pkg.warranty.replaceAll(RegExp(r'\s*years?', caseSensitive: false), '').trim()),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatVltOptions(List<String> options) {
    if (options.isEmpty) return 'N/A';
    final filtered = options
        .map((e) => e.replaceAll(RegExp(r'[^0-9]'), ''))
        .where((e) => e.isNotEmpty)
        .toList();
    if (filtered.isEmpty) return 'N/A';
    return filtered.join(', ');
  }

  String _formatVltRange(List<String> options) {
    if (options.isEmpty) return 'N/A';
    final filtered = options
        .map((e) => e.replaceAll(RegExp(r'[^0-9]'), ''))
        .where((e) => e.isNotEmpty)
        .toList();
    if (filtered.isEmpty) return 'N/A';
    if (filtered.length == 1) return filtered.first;
    return '${filtered.first}-${filtered.last}';
  }

  String _formatPercentageOnly(String text) {
    if (text.isEmpty) return 'N/A';
    final cleaned = text.replaceAll(RegExp(r'[^0-9%.\-\s]'), '').trim();
    if (cleaned.isEmpty) return 'N/A';
    return cleaned;
  }

  void _showPackageDetailsDialog(BuildContext context, TintPackageModel pkg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _gold, width: 2),
          ),
          title: Center(
            child: Text(
              pkg.packageName.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _gold, letterSpacing: 0.5),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                  ),
                  const Divider(color: _gold, thickness: 1.5, height: 24),
                  _buildDetailRow('Film Type', pkg.filmType),
                  _buildDetailRow('Thickness', pkg.thickness),
                  _buildDetailRow('Warranty (Years)', pkg.warranty.replaceAll(RegExp(r'\s*years?', caseSensitive: false), '').trim()),
                  _buildDetailRow('Heat Rejection (IRR-%)', pkg.heatRejection.replaceAll('%', '').trim()),
                  _buildDetailRow('UV Rejection (UVR-%)', pkg.uvRejection.replaceAll('%', '').trim()),
                  _buildDetailRow('Darkness (VLT-%)', _formatVltOptions(pkg.darknessOptions)),
                  const Divider(color: _gold, thickness: 1.5, height: 24),
                  
                  if (pkg.freeItems.isNotEmpty) ...[
                    const Text(
                      'FREE ITEMS INCLUDED',
                      style: TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 10),
                    ...pkg.freeItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: _gold, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Free $item',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(color: _gold, thickness: 1.5, height: 24),
                  ],

                  const Text(
                    'PRICE BY VEHICLE SIZE',
                    style: TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  _buildPriceBreakdownRow('Sedan', pkg.getPriceForVehicle('sedan')),
                  _buildPriceBreakdownRow('SUV', pkg.getPriceForVehicle('suv')),
                  _buildPriceBreakdownRow('MPV', pkg.getPriceForVehicle('mpv')),
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(color: _gold.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownRow(String vehicle, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            vehicle,
            style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Text(
            'RM ${price.toStringAsFixed(0)}',
            style: const TextStyle(color: _gold, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
