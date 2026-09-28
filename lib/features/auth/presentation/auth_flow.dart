import 'package:flutter/material.dart';

import '../application/auth_controller.dart';
import '../../history/data/health_history_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../dashboard/data/health_connect_repository.dart';
import '../../home/presentation/home_shell.dart';
import '../../training/data/exercise_repository.dart';
import '../../training/data/training_readiness_repository.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// A private screen is removed on logout, not kept in the back stack.
class AuthFlow extends StatefulWidget {
  const AuthFlow({
    super.key,
    required this.controller,
    required this.historyRepository,
    required this.profileRepository,
    required this.dashboardRepository,
    required this.trainingReadinessRepository,
    required this.exerciseRepository,
  });

  final AuthController controller;
  final HealthHistoryRepository historyRepository;
  final ProfileRepository profileRepository;
  final HealthConnectRepository dashboardRepository;
  final TrainingReadinessRepository trainingReadinessRepository;
  final ExerciseRepository exerciseRepository;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onAuthChanged);
  }

  @override
  void didUpdateWidget(covariant AuthFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onAuthChanged);
      widget.controller.addListener(_onAuthChanged);
    }
  }

  void _onAuthChanged() {
    setState(() {
      if (widget.controller.user != null) _showRegister = false;
    });
  }

  void _showRegistration(bool value) {
    if (widget.controller.isBusy) return;
    widget.controller.clearError();
    setState(() => _showRegister = value);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.controller;
    final user = auth.user;
    return PopScope(
      canPop: !_showRegister && !auth.isBusy,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showRegister && !auth.isBusy) _showRegistration(false);
      },
      child: user != null
          ? HomeShell(
              key: const Key('history-screen'),
              authController: auth,
              historyRepository: widget.historyRepository,
              profileRepository: widget.profileRepository,
              dashboardRepository: widget.dashboardRepository,
              trainingReadinessRepository: widget.trainingReadinessRepository,
              exerciseRepository: widget.exerciseRepository,
              user: user,
            )
          : _showRegister
          ? RegisterScreen(
              key: const Key('register-screen'),
              controller: auth,
              onLogin: () => _showRegistration(false),
            )
          : LoginScreen(
              key: const Key('login-screen'),
              controller: auth,
              onRegister: () => _showRegistration(true),
            ),
    );
  }
}
