import 'package:flutter/material.dart';

import '../../../theme/healthpal_theme.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_user.dart';
import '../../dashboard/data/health_connect_repository.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../history/data/health_history_repository.dart';
import '../../history/presentation/history_analytics_screen.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/profile_settings_screen.dart';
import '../../training/data/exercise_repository.dart';
import '../../training/data/training_readiness_repository.dart';
import '../../training/presentation/training_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.authController,
    required this.historyRepository,
    required this.profileRepository,
    required this.dashboardRepository,
    required this.trainingReadinessRepository,
    required this.exerciseRepository,
    required this.user,
  });

  final AuthController authController;
  final HealthHistoryRepository historyRepository;
  final ProfileRepository profileRepository;
  final HealthConnectRepository dashboardRepository;
  final TrainingReadinessRepository trainingReadinessRepository;
  final ExerciseRepository exerciseRepository;
  final AuthUser user;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_selectedIndex) {
        0 => DashboardScreen(
          authController: widget.authController,
          repository: widget.dashboardRepository,
          profileRepository: widget.profileRepository,
          user: widget.user,
        ),
        1 => HistoryAnalyticsScreen(
          authController: widget.authController,
          repository: widget.historyRepository,
          user: widget.user,
          onOpenProfile: () => setState(() => _selectedIndex = 3),
        ),
        2 => TrainingScreen(
          readinessRepository: widget.trainingReadinessRepository,
          exerciseRepository: widget.exerciseRepository,
        ),
        _ => ProfileSettingsScreen(
          authController: widget.authController,
          repository: widget.profileRepository,
          user: widget.user,
        ),
      },
      bottomNavigationBar: BottomAppBar(
        key: const Key('home-navigation'),
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _navItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Tổng quan'),
            _navItem(1, Icons.insights_outlined, Icons.insights, 'Lịch sử'),
            _navItem(
              2,
              Icons.fitness_center_outlined,
              Icons.fitness_center,
              'Tập luyện',
            ),
            _navItem(3, Icons.person_outline, Icons.person, 'Hồ sơ'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final selected = _selectedIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          key: Key(
            'nav-${switch (index) {
              0 => 'dashboard',
              1 => 'history',
              2 => 'training',
              _ => 'profile',
            }}',
          ),
          onTap: () => setState(() => _selectedIndex = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : HealthPalColors.secondary,
                  size: 22,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : HealthPalColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
