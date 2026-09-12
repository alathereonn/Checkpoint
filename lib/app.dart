import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/backlog/screens/home_screen.dart';

class CheckpointApp extends ConsumerWidget {
  const CheckpointApp({super.key});
  @override
  Widget build(BuildContext c, WidgetRef r) {
    final a = r.watch(authProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checkpoint',
      theme: AppTheme.dark,
      home: a.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : a.authenticated
          ? const HomeScreen()
          : const AuthScreen(),
    );
  }
}
