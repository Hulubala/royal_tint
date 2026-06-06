import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/core/constants/app_strings.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/providers/customer_booking_provider.dart';

class BookingStep4Review extends StatelessWidget {
  const BookingStep4Review({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerBookingProvider>();
    const gold = Color(0xFFFFD700);

    final dateStr = provider.selectedDate != null ? DateFormat('EEEE, MMM dd, yyyy').format(provider.selectedDate!) : '';
    final timeStr = provider.selectedTimeSlot ?? '';
    final branchName = provider.selectedBranch == 'melaka' ? AppStrings.melakaBranch : AppStrings.seremban2Branch;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'ESTIMATED BILL',
              style: TextStyle(color: gold, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
          ),
          const SizedBox(height: 20),

          _buildReviewRow('Customer', provider.currentCustomer?.name ?? ''),
          _buildReviewRow('Phone', provider.currentCustomer?.phone ?? ''),
          _buildReviewRow('Vehicle', '${provider.selectedBrand?.name ?? ''} ${provider.selectedVehicleModel?.name ?? ''}'),
          _buildReviewRow('Plate', provider.plateController.text.toUpperCase()),
          _buildReviewRow('Type', provider.detectedCarType.toUpperCase()),
          _buildReviewRow('Est. Time', '${provider.estimatedMinutes} minutes'),
          _buildReviewRow('Schedule', '$dateStr at $timeStr'),
          _buildReviewRow('Branch', branchName),
          if (provider.selectedPackage?.warranty != null && provider.selectedPackage!.warranty.isNotEmpty)
            _buildReviewRow('Warranty (Years)', provider.selectedPackage!.warranty.replaceAll(RegExp(r'\s*years?', caseSensitive: false), '').trim()),

          const SizedBox(height: 16),
          const Divider(color: gold, height: 1),
          const SizedBox(height: 16),

          const Text('PACKAGE SELECTION', style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(provider.selectedPackage?.packageName ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),

          const SizedBox(height: 16),
          const Text('TINT SELECTIONS', style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ...TintSections.all.map((key) {
            final code = provider.tintSelections[key] ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(TintSections.labelByKey[key] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(mapSVtoVLT(code), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),

          if (provider.selectedPackage?.freeItems.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            const Text('FREE ITEMS', style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            ...provider.selectedPackage!.freeItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.star, color: gold, size: 10),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 12))),
                ],
              ),
            )),
          ],
          const SizedBox(height: 16),
          const Divider(color: gold, height: 1),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PRICE', style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('RM ${provider.calculatedPrice.toStringAsFixed(2)}', style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    const gold = Color(0xFFFFD700);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          const Text(': ', style: TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
