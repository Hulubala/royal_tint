import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';

class PackageTintSelectionSection extends StatelessWidget {
  final List<TintPackageModel> packages;
  final TintPackageModel? selectedPackage;
  final Map<String, String> tintSelections;
  final bool isSaving;
  final ValueChanged<TintPackageModel?> onPackageChanged;
  final void Function(String sectionKey, String tintVLT) onTintSelectionChanged;

  const PackageTintSelectionSection({
    super.key,
    required this.packages,
    required this.selectedPackage,
    required this.tintSelections,
    required this.isSaving,
    required this.onPackageChanged,
    required this.onTintSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPackageDropdown(),
        const SizedBox(height: 16),
        _buildTintSelections(),
      ],
    );
  }

  Widget _buildPackageDropdown() {
    if (packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: const Row(
          children: [
            Icon(BootstrapIcons.exclamation_triangle, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No packages available. Please add packages first.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return MenuDropdown<String>(
      label: 'Service Package',
      icon: BootstrapIcons.box_seam,
      hint: 'Select package',
      value: selectedPackage?.packageID,
      enabled: !isSaving,
      menuMaxHeight: 320,
      items: packages
          .map((p) => MenuItem<String>(value: p.packageID, label: p.packageName))
          .toList(),
      onChanged: (id) {
        if (id == null) return;
        final pkg = packages.firstWhere((x) => x.packageID == id);
        onPackageChanged(pkg);
      },
    );
  }

  Widget _buildTintSelections() {
    final packageName = selectedPackage?.packageName ?? '';

    MenuDropdown<String> tintDropdown(String label, String key) {
      final allowed = allowedCodesFor(packageName: packageName, sectionKey: key);

      final current = normalizeTintSelection(
        selection: tintSelections[key] ?? '',
        allowedCodes: allowed,
      );

      return MenuDropdown<String>(
        label: label,
        icon: BootstrapIcons.droplet_half,
        value: current.isEmpty ? null : current,
        hint: allowed.isEmpty ? 'No options' : 'Select darkness',
        enabled: allowed.isNotEmpty,
        items: allowed
            .map((code) => MenuItem<String>(value: code, label: code))
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          // Store as VLT (existing system expects VLT in Firestore)
          onTintSelectionChanged(key, mapSVtoVLT(value));
        },
      );
    }

    if (packageName.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: const Text(
          'Please select a package first.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    final anyAllowed = TintSections.all.any((k) =>
        allowedCodesFor(packageName: packageName, sectionKey: k).isNotEmpty);

    if (!anyAllowed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Text(
          'No darkness options available for $packageName. Please update your package settings.',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tintDropdown('Front Windscreen', TintSections.frontWindScreen)),
            const SizedBox(width: 12),
            Expanded(child: tintDropdown('Front Side Windows', TintSections.frontSideWindows)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: tintDropdown('Rear Passenger', TintSections.rearPassenger)),
            const SizedBox(width: 12),
            Expanded(child: tintDropdown('Rear Windscreen', TintSections.rearWindscreen)),
          ],
        ),
      ],
    );
  }
}
