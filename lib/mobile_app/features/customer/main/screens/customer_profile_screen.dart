import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:royal_tint/data/repositories/customer_repository.dart';
import 'package:royal_tint/domain/models/user/customer_model.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/mobile_app/features/common/auth/services/mobile_auth_service.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/customer_header.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/shop_info_panel.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/profile_stat_card.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/profile_account_settings.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/profile_security_settings.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerRepo = CustomerRepository();
  final _authService = MobileAuthService();

  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  bool _isSaving = false;
  bool _isSendingReset = false;

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
      await _customerRepo.updateProfile(
        docID,
        _nameController!.text.trim(),
        _phoneController!.text.trim(),
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
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleSendReset(String email) async {
    setState(() => _isSendingReset = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your registered email.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingReset = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<CustomerModel>(
        stream: _customerRepo.streamCurrentCustomer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: gold));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final customer = snapshot.data;
          if (customer != null) {
            _nameController ??= TextEditingController(text: customer.name);
            _phoneController ??= TextEditingController(text: customer.phone);
          }

          final email = customer?.email ?? '...';

          return Column(
            children: [
              const CustomerHeader(title: 'My Profile'),
              Expanded(
                child: SingleChildScrollView(
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Account Settings Box
                        ProfileAccountSettings(
                          nameController: _nameController,
                          phoneController: _phoneController,
                          email: email,
                          isSaving: _isSaving,
                          onSave: () => _handleSave(customer?.uid ?? ''),
                        ),
                        const SizedBox(height: 20),

                        // Security Settings Box
                        ProfileSecuritySettings(
                          isSendingReset: _isSendingReset,
                          onSendReset: () => _handleSendReset(email),
                        ),
                        const SizedBox(height: 20),

                        const ShopInfoPanel(),
                        const SizedBox(height: 20),

                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: ProfileStatCard(
                                label: 'My Vehicles',
                                value: '${customer?.vehicles.length ?? 0}',
                                icon: BootstrapIcons.car_front,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ProfileStatCard(
                                label: 'Total Bookings',
                                value: '${customer?.totalAppointments ?? 0}',
                                icon: BootstrapIcons.calendar_check,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _customerRepo.signOut();
                              if (context.mounted) context.go('/role');
                            },
                            icon: const Icon(BootstrapIcons.box_arrow_right),
                            label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
