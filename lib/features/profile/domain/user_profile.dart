import '../../auth/domain/auth_user.dart';

enum HealthGoal { maintainHealth, loseWeight, buildMuscle, improveFitness }

enum HealthConnectStatus { disconnected, demo }

class UserProfile {
  const UserProfile({
    required this.user,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.goal = HealthGoal.maintainHealth,
    this.dailyStepGoal = 8000,
    this.healthConnectSync = false,
    this.autoSync = true,
    this.wifiOnly = false,
    this.healthConnectStatus = HealthConnectStatus.disconnected,
  });

  final AuthUser user;
  final DateTime? birthDate;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final HealthGoal goal;
  final int dailyStepGoal;
  final bool healthConnectSync;
  final bool autoSync;
  final bool wifiOnly;
  final HealthConnectStatus healthConnectStatus;

  UserProfile copyWith({
    AuthUser? user,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? gender,
    bool clearGender = false,
    double? heightCm,
    bool clearHeight = false,
    double? weightKg,
    bool clearWeight = false,
    HealthGoal? goal,
    int? dailyStepGoal,
    bool? healthConnectSync,
    bool? autoSync,
    bool? wifiOnly,
    HealthConnectStatus? healthConnectStatus,
  }) {
    return UserProfile(
      user: user ?? this.user,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      gender: clearGender ? null : (gender ?? this.gender),
      heightCm: clearHeight ? null : (heightCm ?? this.heightCm),
      weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
      goal: goal ?? this.goal,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      healthConnectSync: healthConnectSync ?? this.healthConnectSync,
      autoSync: autoSync ?? this.autoSync,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      healthConnectStatus: healthConnectStatus ?? this.healthConnectStatus,
    );
  }
}

extension HealthGoalPresentation on HealthGoal {
  String get label => switch (this) {
    HealthGoal.maintainHealth => 'Duy trì sức khỏe',
    HealthGoal.loseWeight => 'Giảm cân',
    HealthGoal.buildMuscle => 'Tăng cơ',
    HealthGoal.improveFitness => 'Cải thiện thể lực',
  };
}

extension HealthConnectStatusPresentation on HealthConnectStatus {
  String get label => switch (this) {
    HealthConnectStatus.disconnected => 'Chưa kết nối',
    HealthConnectStatus.demo => 'Đang mô phỏng',
  };
}
