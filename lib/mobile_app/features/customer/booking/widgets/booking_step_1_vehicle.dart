import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
import 'package:royal_tint/data/repositories/vehicle_repository.dart';

import 'package:royal_tint/mobile_app/features/customer/booking/providers/customer_booking_provider.dart';

class BookingStep1Vehicle extends StatelessWidget {
  const BookingStep1Vehicle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerBookingProvider>();
    const gold = Color(0xFFFFD700);

    return Form(
      key: provider.formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Read-only customer info
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black, 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: gold),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.person_circle, color: gold, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.currentCustomer?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    Text(provider.currentCustomer?.phone ?? '', style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),

          MenuDropdown<String>(
            label: 'Vehicle Brand',
            labelColor: Colors.black,
            hint: 'Select Brand',
            value: provider.selectedBrand?.brandKey,
            items: provider.brands.map((b) => MenuItem(value: b.brandKey, label: b.name)).toList(),
            enabled: provider.editAppointment == null,
            onChanged: (val) {
              if (val != null) {
                final brand = provider.brands.firstWhere((b) => b.brandKey == val);
                provider.selectBrand(brand);
              }
            },
          ),
          const SizedBox(height: 16),

          if (provider.selectedBrand == null) ...[
            MenuDropdown<String>(
              label: 'Vehicle Model',
              labelColor: Colors.black,
              hint: 'Please select a brand first',
              value: null,
              items: const [],
              onChanged: (val) {},
              enabled: false,
            )
          ] else
            // For model selection, we ideally need to fetch the stream of models. 
            // In the original, it uses a StreamBuilder. 
            // We should use the same here.
            _ModelSelectionDropdown(brandKey: provider.selectedBrand!.brandKey),
          
          if (provider.detectedCarType.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6), border: Border.all(color: gold, width: 1)),
                    child: Text('Type: ${provider.detectedCarType.toUpperCase()}', style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6), border: Border.all(color: gold, width: 1)),
                    child: Text('Est. Time: ${provider.estimatedMinutes} min', style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),

          const Text('Plate Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          const SizedBox(height: 6),
          TextFormField(
            controller: provider.plateController,
            style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'e.g. ABC 1234',
              hintStyle: TextStyle(color: gold.withValues(alpha: 0.35)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: gold, width: 1)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: gold, width: 1)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: gold, width: 2)),
              fillColor: Colors.black,
              filled: true,
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Required';
              if (val.trim().length < 4) return 'Too short';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _ModelSelectionDropdown extends StatelessWidget {
  final String brandKey;
  const _ModelSelectionDropdown({required this.brandKey});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerBookingProvider>();
    const gold = Color(0xFFFFD700);

    return StreamBuilder<List<VehicleModel>>(
      stream: provider.watchModelsByBrandKey(brandKey),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator(color: gold);
        final models = snapshot.data!;
        return MenuDropdown<String>(
          label: 'Vehicle Model',
          labelColor: Colors.black,
          hint: 'Select Model',
          value: provider.selectedVehicleModel?.id,
          items: models.map((m) => MenuItem(value: m.id, label: m.name)).toList(),
          enabled: provider.editAppointment == null,
          onChanged: (val) {
            if (val != null) {
              final model = models.firstWhere((m) => m.id == val);
              provider.selectModel(model);
            }
          },
        );
      }
    );
  }
}
