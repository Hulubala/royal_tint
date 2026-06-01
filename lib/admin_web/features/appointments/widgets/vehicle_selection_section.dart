import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
import 'package:royal_tint/data/repositories/vehicle_repository.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_form_widgets.dart';

class VehicleSelectionSection extends StatelessWidget {
  final VehicleRepository vehicleRepo;
  final VehicleBrand? selectedBrand;
  final VehicleModel? selectedVehicleModel;
  final String detectedCarType;
  final int estimatedMinutes;
  final bool isSaving;
  final ValueChanged<VehicleBrand?> onBrandChanged;
  final ValueChanged<VehicleModel?> onModelChanged;

  const VehicleSelectionSection({
    super.key,
    required this.vehicleRepo,
    required this.selectedBrand,
    required this.selectedVehicleModel,
    required this.detectedCarType,
    required this.estimatedMinutes,
    required this.isSaving,
    required this.onBrandChanged,
    required this.onModelChanged,
  });

  Widget _buildSmartDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final menuItems = items.map((e) {
      final v = e.value;
      final child = e.child;

      String text = '';
      if (child is Text) {
        text = child.data ?? '';
      }
      text = text.isNotEmpty ? text : (v ?? '');

      return MenuItem<String>(
        value: v ?? '',
        label: text,
      );
    }).toList();

    return MenuDropdown<String>(
      label: label,
      icon: icon,
      hint: hint,
      value: value,
      enabled: enabled && !isSaving,
      menuMaxHeight: 320,
      items: menuItems,
      onChanged: (v) => onChanged(v),
    );
  }

  Widget _buildDetectedInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CC)]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.info_circle,
                  color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text('Auto-Detected',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppointmentInfoChip(
                  label: 'Type',
                  value: detectedCarType,
                  icon: BootstrapIcons.car_front_fill,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppointmentInfoChip(
                  label: 'Est. Time',
                  value: '$estimatedMinutes min',
                  icon: BootstrapIcons.clock,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<VehicleBrand>>(
          stream: vehicleRepo.watchBrands(),
          builder: (context, snap) {
            final brands = snap.data ?? [];

            if (snap.hasError) {
              return Text('Brand load error: ${snap.error}',
                  style: const TextStyle(color: Colors.red));
            }

            return _buildSmartDropdown(
              value: selectedBrand?.brandKey,
              label: 'Vehicle Brand',
              icon: BootstrapIcons.car_front,
              hint: brands.isEmpty ? 'No brands found' : 'Select brand',
              items: brands
                  .map((b) => DropdownMenuItem<String>(
                        value: b.brandKey,
                        child: Text(b.name),
                      ))
                  .toList(),
              onChanged: (brandKey) {
                if (brandKey == null) return;
                final brand = brands.firstWhere((b) => b.brandKey == brandKey);
                onBrandChanged(brand);
              },
              validator: (v) => v == null ? 'Select a brand' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        if (selectedBrand == null)
          _buildSmartDropdown(
            value: null,
            label: 'Vehicle Model',
            icon: BootstrapIcons.car_front_fill,
            hint: 'Select brand first',
            items: const [],
            onChanged: (_) {},
            enabled: false,
            validator: (v) => v == null ? 'Select a model' : null,
          )
        else
          StreamBuilder<List<VehicleModel>>(
            stream: vehicleRepo.watchModelsByBrandKey(selectedBrand!.brandKey),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(
                  'Model load error: ${snap.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }

              final models = snap.data ?? [];
              return _buildSmartDropdown(
                value: selectedVehicleModel?.id,
                label: 'Vehicle Model',
                icon: BootstrapIcons.car_front_fill,
                hint: models.isEmpty ? 'No models found' : 'Select model',
                items: models
                    .map((m) => DropdownMenuItem<String>(
                          value: m.id,
                          child: Text(m.name),
                        ))
                    .toList(),
                onChanged: (modelId) {
                  if (modelId == null) return;
                  final model = models.firstWhere((m) => m.id == modelId);
                  onModelChanged(model);
                },
                enabled: models.isNotEmpty,
                validator: (v) => v == null ? 'Select a model' : null,
              );
            },
          ),
        if (detectedCarType.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetectedInfo()
        ],
      ],
    );
  }
}
