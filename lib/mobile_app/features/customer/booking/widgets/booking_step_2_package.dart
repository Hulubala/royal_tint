import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/providers/customer_booking_provider.dart';

class BookingStep2Package extends StatelessWidget {
  const BookingStep2Package({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerBookingProvider>();
    const gold = Color(0xFFFFD700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Tint Package', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
        const SizedBox(height: 6),
        ...provider.packages.map((pkg) {
          final isSelected = provider.selectedPackage?.packageID == pkg.packageID;
          final price = pkg.getPriceForVehicle(provider.detectedCarType.isNotEmpty ? provider.detectedCarType : 'sedan');
          
          return GestureDetector(
            onTap: () => provider.selectPackage(pkg),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? gold : Colors.grey, width: isSelected ? 2.5 : 1),
                boxShadow: isSelected ? [BoxShadow(color: gold.withValues(alpha: 0.2), blurRadius: 8)] : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg.packageName,
                          style: TextStyle(
                            color: isSelected ? gold : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        _buildSpecRow('Darkness\n(VLT - %)', pkg.darknessOptionsText.replaceAll('%', '').trim()),
                        const SizedBox(height: 4),
                        _buildSpecRow('UV Rejection\n(UVR - %)', pkg.uvRejection.replaceAll('%', '').trim()),
                        const SizedBox(height: 4),
                        _buildSpecRow('Heat Rejection\n(IRR - %)', pkg.heatRejection.replaceAll('%', '').trim()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'RM ${price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isSelected ? gold : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        if (provider.selectedPackage != null) ...[
          const SizedBox(height: 12),
          const Text('Tint Darkness Selection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold, width: 1),
            ),
            child: Column(
              children: TintSections.all.map((sectionKey) {
                final allowed = allowedCodesFor(packageName: provider.selectedPackage!.packageName, sectionKey: sectionKey);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MenuDropdown<String>(
                    label: TintSections.labelByKey[sectionKey] ?? sectionKey,
                    labelColor: gold,
                    hint: 'Select VLT',
                    value: provider.tintSelections[sectionKey]?.isNotEmpty == true && allowed.contains(provider.tintSelections[sectionKey])
                        ? provider.tintSelections[sectionKey]
                        : (allowed.isNotEmpty ? allowed.first : null),
                    items: allowed.map((code) => MenuItem(value: code, label: mapSVtoVLT(code))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        provider.updateTintSelection(sectionKey, val);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 85, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
        const Text(':', style: TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(width: 6),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 11))),
      ],
    );
  }
}
