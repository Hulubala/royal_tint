import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class StaffAccountSettingsPanel extends StatefulWidget {
  final String staffID;
  final String initialName;
  final String email;
  final String initialPhone;
  final Future<String?> Function(String staffID, String name, String phone) onSave;

  const StaffAccountSettingsPanel({
    super.key,
    required this.staffID,
    required this.initialName,
    required this.email,
    required this.initialPhone,
    required this.onSave,
  });

  @override
  State<StaffAccountSettingsPanel> createState() => _StaffAccountSettingsPanelState();
}

class _StaffAccountSettingsPanelState extends State<StaffAccountSettingsPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    final error = await widget.onSave(
      widget.staffID,
      _nameController.text.trim(),
      _phoneController.text.trim(),
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (error == null) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account settings saved!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(BootstrapIcons.person_gear, color: gold, size: 20),
                    SizedBox(width: 8),
                    Text('Account Settings', style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(BootstrapIcons.pencil, color: gold, size: 18),
                    onPressed: () => setState(() => _isEditing = true),
                  )
                else
                  IconButton(
                    icon: const Icon(BootstrapIcons.x, color: gold, size: 24),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = widget.initialName;
                        _phoneController.text = widget.initialPhone;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Name Field
            _buildTextField(
              label: 'Full Name',
              controller: _nameController,
              enabled: _isEditing,
              icon: BootstrapIcons.person,
              validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
            ),
            const SizedBox(height: 12),
            
            // Email Field (Read Only)
            _buildReadOnlyField(
              label: 'Email Address',
              value: widget.email,
              icon: BootstrapIcons.envelope,
            ),
            const SizedBox(height: 12),
            
            // Phone Field
            _buildTextField(
              label: 'Phone Number',
              controller: _phoneController,
              enabled: _isEditing,
              icon: BootstrapIcons.telephone,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Phone cannot be empty' : null,
            ),
            
            if (_isEditing) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    const gold = Color(0xFFFFD700);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: gold.withValues(alpha: enabled ? 0.8 : 0.5)),
        prefixIcon: Icon(icon, color: gold.withValues(alpha: enabled ? 0.8 : 0.5), size: 18),
        filled: true,
        fillColor: enabled ? Colors.grey[900] : Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: gold.withValues(alpha: enabled ? 0.5 : 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: gold.withValues(alpha: enabled ? 0.5 : 0.2)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    const gold = Color(0xFFFFD700);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold.withValues(alpha: 0.5), size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: gold.withValues(alpha: 0.5), fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
