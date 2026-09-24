import 'package:flutter/material.dart';

import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/demo_auth_repository.dart';
import 'features/auth/presentation/auth_flow.dart';
import 'features/history/data/demo_health_history_repository.dart';
import 'features/history/data/health_history_repository.dart';
import 'theme/healthpal_theme.dart';

class HealthPalApp extends StatefulWidget {
  const HealthPalApp({super.key, this.authRepository, this.historyRepository});

  final AuthRepository? authRepository;
  final HealthHistoryRepository? historyRepository;

  @override
  State<HealthPalApp> createState() => _HealthPalAppState();
}

class _HealthPalAppState extends State<HealthPalApp> {
  late final AuthController _auth = AuthController(
    repository: widget.authRepository ?? DemoAuthRepository(),
  );
  late final HealthHistoryRepository _historyRepository =
      widget.historyRepository ?? DemoHealthHistoryRepository();

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthPal',
      debugShowCheckedModeBanner: false,
      theme: healthPalTheme,
      home: AuthFlow(controller: _auth, historyRepository: _historyRepository),
    );
  }
}
