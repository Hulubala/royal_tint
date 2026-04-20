import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'profile_panel_decoration.dart';

class ShopSettingsPanel extends StatefulWidget {
  final String branchName;
  final String address;

  final String initialSupportPhone;
  final Map<String, String> initialOperatingHours;

  final bool isSaving;
  final Future<void> Function(String supportPhone, Map<String, String> operatingHours) onSave;

  const ShopSettingsPanel({
    super.key,
    required this.branchName,
    required this.address,
    required this.initialSupportPhone,
    required this.initialOperatingHours,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<ShopSettingsPanel> createState() => _ShopSettingsPanelState();
}

class _ShopSettingsPanelState extends State<ShopSettingsPanel> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _supportPhoneCtrl;

  late final TextEditingController _monCtrl;
  late final TextEditingController _tueCtrl;
  late final TextEditingController _wedCtrl;
  late final TextEditingController _thuCtrl;
  late final TextEditingController _friCtrl;
  late final TextEditingController _satCtrl;
  late final TextEditingController _sunCtrl;

  static const _days = [
    ('monday', 'Monday'),
    ('tuesday', 'Tuesday'),
    ('wednesday', 'Wednesday'),
    ('thursday', 'Thursday'),
    ('friday', 'Friday'),
    ('saturday', 'Saturday'),
    ('sunday', 'Sunday'),
  ];

  @override
  void initState() {
    super.initState();
    _supportPhoneCtrl = TextEditingController(text: widget.initialSupportPhone);

    _monCtrl = TextEditingController(text: widget.initialOperatingHours['monday'] ?? '');
    _tueCtrl = TextEditingController(text: widget.initialOperatingHours['tuesday'] ?? '');
    _wedCtrl = TextEditingController(text: widget.initialOperatingHours['wednesday'] ?? '');
    _thuCtrl = TextEditingController(text: widget.initialOperatingHours['thursday'] ?? '');
    _friCtrl = TextEditingController(text: widget.initialOperatingHours['friday'] ?? '');
    _satCtrl = TextEditingController(text: widget.initialOperatingHours['saturday'] ?? '');
    _sunCtrl = TextEditingController(text: widget.initialOperatingHours['sunday'] ?? '');
  }

  @override
  void didUpdateWidget(covariant ShopSettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSupportPhone != widget.initialSupportPhone) {
      _supportPhoneCtrl.text = widget.initialSupportPhone;
    }

    if (oldWidget.initialOperatingHours != widget.initialOperatingHours) {
      _monCtrl.text = widget.initialOperatingHours['monday'] ?? '';
      _tueCtrl.text = widget.initialOperatingHours['tuesday'] ?? '';
      _wedCtrl.text = widget.initialOperatingHours['wednesday'] ?? '';
      _thuCtrl.text = widget.initialOperatingHours['thursday'] ?? '';
      _friCtrl.text = widget.initialOperatingHours['friday'] ?? '';
      _satCtrl.text = widget.initialOperatingHours['saturday'] ?? '';
      _sunCtrl.text = widget.initialOperatingHours['sunday'] ?? '';
    }
  }

  @override
  void dispose() {
    _supportPhoneCtrl.dispose();
    _monCtrl.dispose();
    _tueCtrl.dispose();
    _wedCtrl.dispose();
    _thuCtrl.dispose();
    _friCtrl.dispose();
    _satCtrl.dispose();
    _sunCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required String label,
    required IconData icon,
    String? helper,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: Color(0xFFFFD700),
        fontWeight: FontWeight.w700,
      ),
      helperText: helper,
      helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
      filled: true,
      fillColor: readOnly ? const Color(0xFF141414) : const Color(0xFF0F0F0F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final operatingHours = <String, String>{
      'monday': _monCtrl.text.trim(),
      'tuesday': _tueCtrl.text.trim(),
      'wednesday': _wedCtrl.text.trim(),
      'thursday': _thuCtrl.text.trim(),
      'friday': _friCtrl.text.trim(),
      'saturday': _satCtrl.text.trim(),
      'sunday': _sunCtrl.text.trim(),
    };

    await widget.onSave(_supportPhoneCtrl.text.trim(), operatingHours);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: profilePanelDecoration(),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(BootstrapIcons.shop, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 10),
                const Text(
                  'Shop Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manage branch contact and operating hours',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            TextFormField(
              readOnly: true,
              initialValue: widget.branchName.isEmpty ? '-' : widget.branchName,
              style: TextStyle(color: Colors.grey[300]),
              decoration: _dec(
                label: 'Branch',
                icon: BootstrapIcons.building,
                helper: 'Read-only',
                readOnly: true,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              readOnly: true,
              initialValue: widget.address.isEmpty ? '-' : widget.address,
              style: TextStyle(color: Colors.grey[300]),
              maxLines: 2,
              decoration: _dec(
                label: 'Shop Address',
                icon: BootstrapIcons.geo_alt_fill,
                helper: 'Read-only (update in branches collection if needed)',
                readOnly: true,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _supportPhoneCtrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFFFFD700),
              decoration: _dec(
                label: 'Phone Support',
                icon: BootstrapIcons.telephone_fill,
                helper: 'This updates branches/<branchId>.phone',
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Support phone is required';
                if (s.length < 8) return 'Phone looks too short';
                return null;
              },
            ),

            const SizedBox(height: 22),

            const Text(
              'Operating Hours',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter text like "9:00 AM - 7:00 PM" or "Closed".',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 14),

            _dayField(label: _days[0].$2, controller: _monCtrl),
            const SizedBox(height: 12),
            _dayField(label: _days[1].$2, controller: _tueCtrl),
            const SizedBox(height: 12),
            _dayField(label: _days[2].$2, controller: _wedCtrl),
            const SizedBox(height: 12),
            _dayField(label: _days[3].$2, controller: _thuCtrl),
            const SizedBox(height: 12),
            _dayField(label: _days[4].$2, controller: _friCtrl),
            const SizedBox(height: 12),
            _dayField(label: _days[5].$2, controller: _satCtrl),
            const SizedBox(height: 12),
            _dayField(label: _days[6].$2, controller: _sunCtrl),

            const SizedBox(height: 22),

            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: widget.isSaving ? null : _submit,
                  icon: widget.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(BootstrapIcons.save2_fill),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      cursorColor: const Color(0xFFFFD700),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: Color(0xFFFFD700),
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFF0F0F0F),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
      ),
      validator: (v) {
        final s = (v ?? '').trim();
        if (s.isEmpty) return 'Required';
        return null;
      },
    );
  }
}