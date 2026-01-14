import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; 
import 'package:royal_tint/core/routes/app_router.dart';
import 'package:royal_tint/core/theme/app_theme.dart';
import 'package:royal_tint/features/auth/providers/auth_provider.dart';
import 'package:royal_tint/features/manager/providers/manager_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ManagerProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Get AuthProvider from context
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          
          return MaterialApp.router(
            title: 'Royal Tint Digital Platform',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router(authProvider),
          );
        },
      ),
    );
  }
}