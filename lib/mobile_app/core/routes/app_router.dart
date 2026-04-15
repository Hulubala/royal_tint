import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileAppRouter {
  static GoRouter router() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'mobile-home',
          builder: (context, state) => const _MobileHomePlaceholder(),
        ),
      ],
    );
  }
}

class _MobileHomePlaceholder extends StatelessWidget {
  const _MobileHomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mobile router is working. Add your real screens here.'),
      ),
    );
  }
}