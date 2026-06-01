import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class StaffAccountSettings extends StatelessWidget {
  final TextEditingController? nameController;
  final TextEditingController? phoneController;
  final String email;
  final bool isSaving;
  final VoidCallback onSave;

  const StaffAccountSettings({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.email,
    required this.isSaving,
    required this.onSave,
  });

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color gold,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled && !isSaving,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      cursorColor: gold,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: gold.withValues(alpha: 0.6), fontSize: 13),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon, color: gold.withValues(alpha: 0.7), size: 18),
        filled: true,
        fillColor: const Color(0xFF121212),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.1), width: 1),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon, Color gold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold.withValues(alpha: 0.4), size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: gold.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.person_badge_fill, color: gold, size: 18),
              SizedBox(width: 10),
              Text(
                'Account Settings',
                style: TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (nameController != null)
            _buildEditableField(
              label: 'Full Name',
              controller: nameController!,
              icon: BootstrapIcons.person,
              gold: gold,
            ),
          
          const SizedBox(height: 14),
          _buildReadOnlyField('Email Address', email, BootstrapIcons.envelope, gold),
          const SizedBox(height: 14),
          
          if (phoneController != null)
            _buildEditableField(
              label: 'Phone Number',
              controller: phoneController!,
              icon: BootstrapIcons.telephone,
              gold: gold,
            ),
            
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                    )
                  : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
