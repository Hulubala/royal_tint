import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/data/repositories/staff_repository.dart';
import 'package:royal_tint/domain/models/user/staff_model.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_header.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_security_settings_panel.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_account_settings.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_shop_info_panel.dart';
import 'package:royal_tint/mobile_app/features/staff/main/widgets/staff_stat_card.dart';

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

  Future<void> _handleSave(String docID) async {
    if (docID.isEmpty || _nameController == null || _phoneController == null) return;

    setState(() => _isSaving = true);

    try {
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
                                      color: Colors.black.withValues(alpha: 0.15),
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
                                  border: Border.all(color: gold.withValues(alpha: 0.5)),
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
                        StaffAccountSettings(
                          nameController: _nameController,
                          phoneController: _phoneController,
                          email: email,
                          isSaving: _isSaving,
                          onSave: () => _handleSave(staff?.staffID ?? ''),
                        ),
                        const SizedBox(height: 16),

                        // Security Settings
                        StaffSecuritySettingsPanel(
                          email: email,
                          onSendReset: _staffRepo.sendPasswordResetEmail,
                        ),
                        const SizedBox(height: 16),
                          
                        const StaffShopInfoPanel(),
                        const SizedBox(height: 16),
                          
                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: StaffStatCard(
                                label: 'Tasks Done',
                                value: '${staff?.currentTaskCount ?? 0}', 
                                icon: BootstrapIcons.check2_square,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StaffStatCard(
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
}
