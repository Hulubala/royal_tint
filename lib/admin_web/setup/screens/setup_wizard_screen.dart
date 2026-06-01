import 'package:flutter/material.dart';
import 'package:royal_tint/data/services/initial_setup_service.dart';
import 'package:royal_tint/admin_web/setup/widgets/setup_wizard_widgets.dart';

/// Comprehensive Firebase Setup Wizard Screen
/// Run this ONCE to initialize Royal Tint database
class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen>
    with SingleTickerProviderStateMixin {
  final InitialSetupService _initialSetupService = InitialSetupService();
  
  bool _isLoading = false;
  bool _isChecking = true;
  bool _setupAlreadyComplete = false;
  String _currentStatus = '';
  final List<String> _logs = [];
  bool _setupSuccess = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    _checkSetupStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkSetupStatus() async {
    setState(() {
      _isChecking = true;
      _currentStatus = 'Checking setup status...';
    });

    try {
      bool isComplete = await _initialSetupService.isSetupComplete();
      setState(() {
        _setupAlreadyComplete = isComplete;
        _isChecking = false;
        if (isComplete) {
          _currentStatus = 'Setup has already been completed';
        } else {
          _currentStatus = 'Ready to begin setup';
        }
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _currentStatus = 'Error checking setup status';
      });
    }
  }

  Future<void> _runSetup() async {
    setState(() {
      _isLoading = true;
      _setupSuccess = false;
      _logs.clear();
    });

    try {
      Map<String, dynamic> result = await _initialSetupService.runCompleteSetup(
        onProgress: (status) {
          setState(() {
            _currentStatus = status;
          });
        },
      );

      setState(() {
        _setupSuccess = result['success'];
        _logs.addAll(List<String>.from(result['logs']));
        _currentStatus = result['message'];
        _isLoading = false;
      });

      if (_setupSuccess) {
        _setupAlreadyComplete = true;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentStatus = 'Setup failed: $e';
        _logs.add('❌ Fatal error: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF1A1A1A),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SetupWizardHeader(),
                  
                  const SizedBox(height: 32),
                  
                  if (_isChecking) 
                    SetupWizardLoadingCard(currentStatus: _currentStatus),
                  
                  if (!_isChecking && !_setupAlreadyComplete)
                    ...[
                      const SetupWizardWarningCard(),
                      const SizedBox(height: 24),
                      const SetupWizardInfoCard(),
                      const SizedBox(height: 24),
                      SetupWizardRunButton(isLoading: _isLoading, onRun: _runSetup),
                    ],
                  
                  if (_setupAlreadyComplete)
                    ...[
                      const SetupWizardCompleteCard(),
                      const SizedBox(height: 24),
                      const SetupWizardLoginButton(),
                    ],
                  
                  if (_currentStatus.isNotEmpty && !_isChecking)
                    ...[
                      const SizedBox(height: 24),
                      SetupWizardStatusCard(
                        isSuccess: _setupSuccess || _setupAlreadyComplete,
                        isError: _currentStatus.contains('failed') || _currentStatus.contains('Error'),
                        currentStatus: _currentStatus,
                      ),
                    ],
                  
                  if (_logs.isNotEmpty)
                    ...[
                      const SizedBox(height: 24),
                      SetupWizardLogsCard(logs: _logs),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}