import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'profile_panel_decoration.dart';

class AccountSettingsPanel extends StatefulWidget {
  final String initialName;
  final String email; // read-only
  final String initialPhone;

  final bool isSaving;
  final Future<void> Function(String name, String phone) onSave;

  const AccountSettingsPanel({
    super.key,
    required this.initialName,
    required this.email,
    required this.initialPhone,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<AccountSettingsPanel> createState() => _AccountSettingsPanelState();
}

class _AccountSettingsPanelState extends State<AccountSettingsPanel> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _emailCtrl = TextEditingController(text: widget.email);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
  }

  @override
  void didUpdateWidget(covariant AccountSettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If provider reloads data, refresh controllers
    if (oldWidget.initialName != widget.initialName) {
      _nameCtrl.text = widget.initialName;
    }
    if (oldWidget.email != widget.email) {
      _emailCtrl.text = widget.email;
    }
    if (oldWidget.initialPhone != widget.initialPhone) {
      _phoneCtrl.text = widget.initialPhone;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
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
    await widget.onSave(_nameCtrl.text, _phoneCtrl.text);
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
            _panelTitle(
              icon: BootstrapIcons.gear_fill,
              title: 'Account Settings',
              subtitle: 'Update your name and phone number',
            ),
            const SizedBox(height: 18),

            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFFFFD700),
              decoration: _dec(
                label: 'Full Name',
                icon: BootstrapIcons.person_fill,
                helper: 'As shown in manager records',
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Full name is required';
                if (s.length < 2) return 'Name is too short';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailCtrl,
              readOnly: true,
              style: TextStyle(color: Colors.grey[300]),
              decoration: _dec(
                label: 'Email Address',
                icon: BootstrapIcons.envelope_fill,
                helper: 'Email cannot be changed here',
                readOnly: true,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneCtrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFFFFD700),
              decoration: _dec(
                label: 'Phone Number',
                icon: BootstrapIcons.telephone_fill,
                helper: 'Example: +60123456789',
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Phone number is required';
                if (s.length < 8) return 'Phone number looks too short';
                return null;
              },
            ),

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
                  label: Text(
                    'Save Changes',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panelTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFFFD700), size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}