import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/data/repositories/staff_repository.dart';
import 'package:royal_tint/domain/models/user/staff_model.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_header.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_security_settings_panel.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _staffRepo = StaffRepository();
  
  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController?.dispose();
    _phoneController?.dispose();
    super.dispose();
  }

  // FIXED: Removed 'const' from constructors using the dynamic variable 'gold'
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color gold,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled && !_isSaving,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      cursorColor: gold,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: gold.withOpacity(0.6), fontSize: 13),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon, color: gold.withOpacity(0.7), size: 18),
        filled: true,
        fillColor: const Color(0xFF121212),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withOpacity(0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold, width: 1.5), // Fixed constant error here
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withOpacity(0.1), width: 1),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon, Color gold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold.withOpacity(0.4), size: 18),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: gold.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: 'Profile'),
          Expanded(
            child: StreamBuilder<StaffModel?>(
              stream: _staffRepo.watchCurrentStaff(),
              builder: (context, snapshot) {
                final staff = snapshot.data;
                final branch = staff?.branchName ?? '...';
                final email = staff?.email ?? '...';

                if (staff != null) {
                  _nameController ??= TextEditingController(text: staff.name);
                  _phoneController ??= TextEditingController(text: staff.phone);
                }

                if (snapshot.connectionState == ConnectionState.waiting && staff == null) {
                  return const Center(child: CircularProgressIndicator(color: gold));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                  border: Border.all(color: gold, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(BootstrapIcons.person_fill, size: 42, color: gold),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: gold.withOpacity(0.5)),
                                ),
                                child: Text(
                                  branch,
                                  style: const TextStyle(color: gold, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Account Settings Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: gold.withOpacity(0.3), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(BootstrapIcons.person_badge_fill, color: gold, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  'Account Settings',
                                  style: TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              if (_nameController != null)
                                _buildEditableField(
                                  label: 'Full Name',
                                  controller: _nameController!,
                                  icon: BootstrapIcons.person,
                                  gold: gold,
                                ),
                              
                              const SizedBox(height: 14),
                              _buildReadOnlyField('Email Address', email, BootstrapIcons.envelope, gold),
                              const SizedBox(height: 14),
                              
                              if (_phoneController != null)
                                _buildEditableField(
                                  label: 'Phone Number',
                                  controller: _phoneController!,
                                  icon: BootstrapIcons.telephone,
                                  gold: gold,
                                ),
                                
                              const SizedBox(height: 20),
                              
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : () => _handleSave(staff?.staffID ?? ''),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: gold,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  child: _isSaving
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
                        ),
                        const SizedBox(height: 16),

                        // Security Settings
                        StaffSecuritySettingsPanel(
                          email: email,
                          onSendReset: _staffRepo.sendPasswordResetEmail,
                        ),
                        const SizedBox(height: 16),
                          
                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Tasks Done',
                                value: '${staff?.currentTaskCount ?? 0}', 
                                icon: BootstrapIcons.check2_square,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                label: 'Status',
                                value: staff?.isActive == true ? 'Active' : 'Inactive',
                                icon: BootstrapIcons.shield_check,
                              ),
                            ),
                          ],
                        ),
                          
                        const SizedBox(height: 32),
                          
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _staffRepo.signOut();
                              if (context.mounted) context.go('/role');
                            },
                            icon: const Icon(BootstrapIcons.box_arrow_right),
                            label: const Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),  
        ],
      ),
    );    
  }

  Future<void> _handleSave(String docID) async {
    if (docID.isEmpty || _nameController == null || _phoneController == null) return;

    setState(() => _isSaving = true);

    try {
      // FIXED: Converted from named parameters to 3 positional parameters
      await _staffRepo.updateProfile(
        docID,
        _nameController!.text,
        _phoneController!.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// FIXED: Defined _StatCard safely out here at the bottom file scope level
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: gold, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: gold.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}