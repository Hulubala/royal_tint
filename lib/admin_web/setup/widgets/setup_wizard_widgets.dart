import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/core/design_system/app_colors.dart';
import 'package:go_router/go_router.dart';

class SetupWizardHeader extends StatelessWidget {
  const SetupWizardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            BootstrapIcons.gear_fill,
            color: Colors.black,
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Royal Tint',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Firebase Setup Wizard',
          style: TextStyle(
            color: AppColors.grey300,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class SetupWizardLoadingCard extends StatelessWidget {
  final String currentStatus;
  const SetupWizardLoadingCard({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            currentStatus,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SetupWizardWarningCard extends StatelessWidget {
  const SetupWizardWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            BootstrapIcons.exclamation_triangle_fill,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            '⚠️ ONE-TIME SETUP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'This wizard will initialize your Firebase database with:\n• 2 Branch locations\n• 2 Manager accounts\n• 5 Tint packages (with pricing for sedan/SUV/MPV)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Run this ONLY ONCE during initial deployment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SetupWizardInfoCard extends StatelessWidget {
  const SetupWizardInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.list_check, color: AppColors.gold, size: 24),
              SizedBox(width: 12),
              Text(
                'What Will Be Created',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSetupItem(
            '📍 Branches',
            '2 branch locations (Melaka & Seremban 2)',
            [
              'Royal Tint Melaka',
              'Royal Tint Seremban 2',
            ],
          ),
          const SizedBox(height: 16),
          _buildSetupItem(
            '👤 Manager Accounts',
            '2 manager accounts with login credentials',
            [
              'Steven Ting - steven.melaka@royaltint.com',
              'Alex Tan - alex.seremban2@royaltint.com',
            ],
          ),
          const SizedBox(height: 16),
          _buildSetupItem(
            '📦 Tint Packages',
            '5 promotional packages with vehicle-based pricing',
            [
              'Package A - Dyed Film (RM 148-298)',
              'Package B - HD Dyed Carbon Film & Dyed Film (RM 248-398)',
              'Package C - HD Dyed Carbon Film (RM 348-498)',
              'Package D - HD Nano Ceramic Film & HD Dyed Carbon Film (RM 488-688)',
              'Package E - HD Nano Ceramic Film (RM 688-988)',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetupItem(String title, String subtitle, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.grey300,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: AppColors.gold)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: AppColors.grey300,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class SetupWizardRunButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRun;

  const SetupWizardRunButton({super.key, required this.isLoading, required this.onRun});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onRun,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        disabledBackgroundColor: AppColors.grey600,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        shadowColor: AppColors.gold.withValues(alpha: 0.5),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(BootstrapIcons.rocket_takeoff_fill, color: Colors.black, size: 24),
                SizedBox(width: 12),
                Text(
                  'START SETUP',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
    );
  }
}

class SetupWizardCompleteCard extends StatelessWidget {
  const SetupWizardCompleteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            BootstrapIcons.check_circle_fill,
            color: Colors.white,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            '✅ Setup Complete!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Your Firebase database has been initialized.\nYou can now login to the manager portal.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SetupWizardLoginButton extends StatelessWidget {
  const SetupWizardLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go('/manager/login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.box_arrow_in_right, color: Colors.black, size: 20),
          SizedBox(width: 12),
          Text(
            'GO TO LOGIN',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class SetupWizardStatusCard extends StatelessWidget {
  final bool isSuccess;
  final bool isError;
  final String currentStatus;

  const SetupWizardStatusCard({
    super.key,
    required this.isSuccess,
    required this.isError,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColors.success.withValues(alpha: 0.2)
            : isError
                ? AppColors.error.withValues(alpha: 0.2)
                : AppColors.info.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? AppColors.success
              : isError
                  ? AppColors.error
                  : AppColors.info,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? BootstrapIcons.check_circle_fill
                : isError
                    ? BootstrapIcons.x_circle_fill
                    : BootstrapIcons.info_circle_fill,
            color: isSuccess
                ? AppColors.success
                : isError
                    ? AppColors.error
                    : AppColors.info,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              currentStatus,
              style: TextStyle(
                color: isSuccess
                    ? AppColors.success
                    : isError
                        ? AppColors.error
                        : AppColors.info,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SetupWizardLogsCard extends StatelessWidget {
  final List<String> logs;

  const SetupWizardLogsCard({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey600, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.terminal, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Setup Logs',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: logs.map((log) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      log,
                      style: TextStyle(
                        color: log.contains('❌')
                            ? AppColors.error
                            : log.contains('✅')
                                ? AppColors.success
                                : log.contains('⚠️')
                                    ? AppColors.warning
                                    : AppColors.grey300,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
