import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mobile_app/core/auth/shared_preferences_helper.dart';

import 'firebase_options.dart';
import 'package:royal_tint/core/theme/app_theme.dart';

// Routers
import 'package:royal_tint/admin_web/core/routes/app_router.dart' as admin_router;
import 'package:royal_tint/mobile_app/core/routes/app_router.dart' as mobile_router;

import 'package:royal_tint/admin_web/core/theme/admin_theme.dart';
//import 'package:royal_tint/mobile_app/core/theme/mobile_theme.dart';

// Admin providers (only created when admin_web boots)
import 'package:royal_tint/admin_web/features/auth/providers/auth_provider.dart' as admin_auth;
import 'package:royal_tint/admin_web/features/dashboard/providers/manager_provider.dart';
import 'package:royal_tint/admin_web/features/manager_shell/providers/manager_shell_provider.dart';
import 'package:royal_tint/admin_web/features/appointments/providers/appointment_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/register_staff/providers/staff_registration_provider.dart';
import 'package:royal_tint/admin_web/features/staff_management/staff_tasks/providers/staff_tasks_provider.dart';
import 'package:royal_tint/admin_web/features/profiles/providers/profile_provider.dart';
import 'package:royal_tint/admin_web/features/feedback/providers/feedback_provider.dart';
import 'package:royal_tint/admin_web/features/sales_reports/providers/sales_report_provider.dart';
enum AppTarget { adminWeb, mobileApp }

AppTarget _resolveAppTarget() {
  // Compile-time env value:
  // flutter run --dart-define=APP_TARGET=admin_web
  // flutter run --dart-define=APP_TARGET=mobile_app
  const raw = String.fromEnvironment('APP_TARGET');

  switch (raw) {
    case 'admin_web':
      return AppTarget.adminWeb;
    case 'mobile_app':
      return AppTarget.mobileApp;
    case '':
      // Fallback if not provided:
      return kIsWeb ? AppTarget.adminWeb : AppTarget.mobileApp;
    default:
      // If typo, fallback too (you can also assert/throw).
      return kIsWeb ? AppTarget.adminWeb : AppTarget.mobileApp;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final target = _resolveAppTarget();
  final isCustomer = await SharedPreferencesHelper.getUserRoleFromPreferences(); 
  runApp(MyApp(appTarget: target, isCustomer: isCustomer));
}

class MyApp extends StatefulWidget {
  final AppTarget appTarget;
  final bool isCustomer;

  const MyApp({super.key, required this.appTarget, required this.isCustomer});

  @override
    State<MyApp> createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> {
    @override
    void initState() {
      super.initState();

      // Option 1: Force logout every launch (ADMIN WEB only)
      if (widget.appTarget == AppTarget.adminWeb) {
        FirebaseAuth.instance.signOut();
      }
    }

  @override
  Widget build(BuildContext context) {
    // ADMIN WEB APP
    if (widget.appTarget == AppTarget.adminWeb) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => admin_auth.AuthProvider()),
          ChangeNotifierProvider(create: (_) => ManagerProvider()),
          ChangeNotifierProvider(create: (_) => ManagerShellProvider()),
          ChangeNotifierProvider(create: (_) => AppointmentProvider()),
          ChangeNotifierProvider(create: (_) => StaffRegistrationProvider()),
          ChangeNotifierProvider(create: (_) => StaffTasksProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => FeedbackProvider()),
          ChangeNotifierProvider(create: (_) => SalesReportProvider()),
        ],
        child: Builder(
          builder: (context) {
            final authProvider =
                Provider.of<admin_auth.AuthProvider>(context, listen: false);

            return MaterialApp.router(
              title: 'Royal Tint Digital Platform (Admin)',
              debugShowCheckedModeBanner: false,
              theme: AdminTheme.theme,
              routerConfig: admin_router.AdminWebAppRouter.router(authProvider),
            );
          },
        ),
      );
    }

    // MOBILE APP
    return MaterialApp.router(
      title: 'Royal Tint (Mobile)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: mobile_router.MobileAppRouter.router(),
    );
  }
}