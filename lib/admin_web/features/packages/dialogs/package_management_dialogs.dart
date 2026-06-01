import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';

// ==========================================
// VIEW PACKAGE DIALOG
// ==========================================
class ViewPackageDialog extends StatelessWidget {
  final TintPackageModel package;

  const ViewPackageDialog({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold, width: 2),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    package.packageName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: gold),
                  ),
                ],
              ),
              Divider(color: gold.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              
              Text(
                'RM${package.getPriceForVehicle('sedan').toStringAsFixed(0)} Full Car Tinted',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 16),
              
              // Specs List
              if (package.filmType.isNotEmpty)
                _buildSpecPoint(package.filmType, ''),
              _buildSpecPoint('Heat Rejection (IRR-%): ', package.heatRejection.replaceAll(RegExp(r'[a-zA-Z%]'), '').replaceAll('-', ' - ').trim()),
              _buildSpecPoint('UV Rejection (UVR-%): ', package.uvRejection.replaceAll(RegExp(r'[a-zA-Z%]'), '').replaceAll('-', ' - ').trim()),
              _buildSpecPoint('Darkness (VLT-%): ', package.darknessOptions
                  .map((e) => e.replaceAll(RegExp(r'[^0-9]'), '').trim())
                  .where((e) => e.isNotEmpty)
                  .join(', ')),
              _buildSpecPoint('Thickness: ', package.thickness),
              _buildSpecPoint('Warranty (Years): ', package.warranty.replaceAll(RegExp(r'\s*years?', caseSensitive: false), '').trim()),
              
              const SizedBox(height: 16),
              if (package.freeItems.isNotEmpty)
                ...package.freeItems.map((item) => Text('★ Free $item', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              
              const SizedBox(height: 24),
              
              // Pricing List
              _buildPriceRow('Sedan', package.getPriceForVehicle('sedan')),
              _buildPriceRow('SUV', package.getPriceForVehicle('suv')),
              _buildPriceRow('MPV', package.getPriceForVehicle('mpv')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String vehicle, double price) {
    const gold = Color(0xFFFFD700);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$vehicle【RM${price.toStringAsFixed(0)}】', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: gold)),
    );
  }

  Widget _buildSpecPoint(String title, String value) {
    if (title.isEmpty && value.isEmpty) return const SizedBox.shrink();
    if (value.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title, style: const TextStyle(fontSize: 15, color: Colors.white)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$title$value', style: const TextStyle(fontSize: 15, color: Colors.white)),
    );
  }
}

// ==========================================
// EDIT / ADD PACKAGE DIALOG
// ==========================================
class PackageEditDialog extends StatefulWidget {
  final TintPackageModel? package;

  const PackageEditDialog({super.key, this.package});

  @override
  State<PackageEditDialog> createState() => _PackageEditDialogState();
}

class _PackageEditDialogState extends State<PackageEditDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _filmTypeCtrl;
  late TextEditingController _irrCtrl;
  late TextEditingController _uvrCtrl;
  late TextEditingController _vltCtrl;
  late TextEditingController _thicknessCtrl;
  late TextEditingController _warrantyCtrl;
  late TextEditingController _freeItemsCtrl;
  
  late TextEditingController _sedanPriceCtrl;
  late TextEditingController _suvPriceCtrl;
  late TextEditingController _mpvPriceCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.package;
    _nameCtrl = TextEditingController(text: p?.packageName ?? '');
    _filmTypeCtrl = TextEditingController(text: p?.filmType ?? '');
    _irrCtrl = TextEditingController(text: p?.heatRejection.replaceAll('%', '').trim() ?? '');
    _uvrCtrl = TextEditingController(text: p?.uvRejection.replaceAll('%', '').trim() ?? '');
    _vltCtrl = TextEditingController(text: p?.darknessOptions.map((e) => e.replaceAll('%', '').trim()).join(', ') ?? '');
    _thicknessCtrl = TextEditingController(text: p?.thickness ?? '');
    _warrantyCtrl = TextEditingController(text: p?.warranty.replaceAll(RegExp(r'\s*years?', caseSensitive: false), '').trim() ?? '');
    _freeItemsCtrl = TextEditingController(text: p?.freeItems.join(', ') ?? '');
    
    _sedanPriceCtrl = TextEditingController(text: p?.getPriceForVehicle('sedan').toStringAsFixed(0) ?? '');
    _suvPriceCtrl = TextEditingController(text: p?.getPriceForVehicle('suv').toStringAsFixed(0) ?? '');
    _mpvPriceCtrl = TextEditingController(text: p?.getPriceForVehicle('mpv').toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _filmTypeCtrl.dispose();
    _irrCtrl.dispose();
    _uvrCtrl.dispose();
    _vltCtrl.dispose();
    _thicknessCtrl.dispose();
    _warrantyCtrl.dispose();
    _freeItemsCtrl.dispose();
    _sedanPriceCtrl.dispose();
    _suvPriceCtrl.dispose();
    _mpvPriceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final p = TintPackageModel(
      packageID: widget.package?.packageID ?? '', // Empty string for new package
      packageName: _nameCtrl.text,
      description: widget.package?.description ?? '',
      originalPrice: double.tryParse(_sedanPriceCtrl.text) ?? 0,
      filmType: _filmTypeCtrl.text,
      heatRejection: _irrCtrl.text,
      uvRejection: _uvrCtrl.text,
      darknessOptions: _vltCtrl.text.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty).toList(),
      thickness: _thicknessCtrl.text,
      warranty: _warrantyCtrl.text,
      duration: widget.package?.duration ?? {'sedan': 180, 'suv': 210, 'mpv': 240},
      freeItems: _freeItemsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      pricing: {
        'sedan': double.tryParse(_sedanPriceCtrl.text) ?? 0,
        'suv': double.tryParse(_suvPriceCtrl.text) ?? 0,
        'mpv': double.tryParse(_mpvPriceCtrl.text) ?? 0,
      },
      features: widget.package?.features ?? [],
      isActive: widget.package?.isActive ?? true,
      createdAt: widget.package?.createdAt,
      updatedAt: DateTime.now(),
    );
    
    Navigator.of(context).pop(p);
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    final isNew = widget.package == null;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold, width: 2),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isNew ? 'Add New Package' : 'Edit Package',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: gold),
                  ),
                ],
              ),
              Divider(color: gold.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field('Package Name', _nameCtrl, 'e.g. Package A'),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _field('Film Type', _filmTypeCtrl, 'e.g. HD Dyed Carbon Film')),
                          const SizedBox(width: 16),
                          Expanded(child: _field('Warranty (Years)', _warrantyCtrl, 'e.g. 5', isWarranty: true)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _field('Heat Rejection (IRR-%)', _irrCtrl, 'e.g. 90-95', isPercentage: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _field('UV Rejection (UVR-%)', _uvrCtrl, 'e.g. 99', isPercentage: true)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _field('Darkness (VLT-%)', _vltCtrl, 'e.g. 70 50 35', isPercentage: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _field('Thickness', _thicknessCtrl, 'e.g. 2 ply Films')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _field('Free Items (comma separated)', _freeItemsCtrl, 'e.g. 8" Sun Block, rm50 voucher'),
                      const SizedBox(height: 24),
                      
                      const Text('Pricing', style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _field('Sedan (RM)', _sedanPriceCtrl, '148', isPrice: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _field('SUV (RM)', _suvPriceCtrl, '198', isPrice: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _field('MPV (RM)', _mpvPriceCtrl, '298', isPrice: true)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Save Package', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {bool isNumber = false, bool isPrice = false, bool isWarranty = false, bool isPercentage = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: (isNumber || isPrice || isWarranty) ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          inputFormatters: [
            if (isNumber || isPrice || isWarranty) FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (isPrice) {
              final val = double.tryParse(v) ?? 0;
              if (val > 10000) return 'Max RM 10000';
            }
            if (isPercentage) {
              final matches = RegExp(r'\d+').allMatches(v);
              for (final m in matches) {
                final val = int.tryParse(m.group(0)!) ?? 0;
                if (val < 0 || val > 99) {
                  return 'Values must be 0-99';
                }
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.black,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFD700)),
            ),
          ),
        ),
      ],
    );
  }
}