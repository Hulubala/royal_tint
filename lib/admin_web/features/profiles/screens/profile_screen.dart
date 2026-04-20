// lib/admin_web/features/profiles/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:royal_tint/admin_web/features/profiles/providers/profile_provider.dart';
import 'package:royal_tint/admin_web/features/profiles/widgets/profile_header_panel.dart';
import 'package:royal_tint/admin_web/features/profiles/widgets/account_settings_panel.dart';
import 'package:royal_tint/admin_web/features/profiles/widgets/security_settings_panel.dart';
import 'package:royal_tint/admin_web/features/profiles/widgets/shop_settings_panel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() => context.read<ProfileProvider>().load());
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();

    return Container(
      color: const Color(0xFFF5F5F5), // outside white like your admin pages
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: p.isLoading
              ? const Center(child: CircularProgressIndicator())
              : p.error != null
                  ? _ErrorState(message: p.error!, onRetry: () => p.load())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeaderPanel(
                          managerName: p.manager?.name ?? '',
                          branchName: p.manager?.branchName ?? '',
                        ),
                        const SizedBox(height: 18),

                        AccountSettingsPanel(
                          initialName: p.manager?.name ?? '',
                          email: p.manager?.email ?? '',
                          initialPhone: p.manager?.phone ?? '',
                          isSaving: p.savingAccount,
                          onSave: (name, phone) async {
                            final err = await context
                                .read<ProfileProvider>()
                                .saveAccountSettings(name: name, phone: phone);
                            if (err == null) {
                              _snack('Account settings saved');
                            } else {
                              _snack(err, isError: true);
                            }
                          },
                        ),

                        const SizedBox(height: 18),

                        SecuritySettingsPanel(
                          email: p.manager?.email ?? '',
                          isSending: p.sendingReset,
                          onSendReset: () async {
                            final err =
                                await context.read<ProfileProvider>().sendResetPassword();
                            if (err == null) {
                              _snack('Password reset link sent to your email');
                            } else {
                              _snack(err, isError: true);
                            }
                          },
                        ),

                        const SizedBox(height: 18),

                        ShopSettingsPanel(
                          branchName: p.branch?.branchName ?? '',
                          address: p.branch?.address ?? '',
                          initialSupportPhone: p.branch?.phone ?? '',
                          initialOperatingHours: p.branch?.operatingHours ?? const {},
                          isSaving: p.savingShop,
                          onSave: (supportPhone, operatingHours) async {
                            final err = await context.read<ProfileProvider>().saveShopSettings(
                                  supportPhone: supportPhone,
                                  operatingHours: operatingHours,
                                );
                            if (err == null) {
                              _snack('Shop settings saved');
                            } else {
                              _snack(err, isError: true);
                            }
                          },
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Failed to load profile', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}