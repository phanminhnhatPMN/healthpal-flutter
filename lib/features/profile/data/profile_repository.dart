import '../domain/user_profile.dart';
import '../../auth/domain/auth_user.dart';

abstract interface class ProfileRepository {
  void ensure(AuthUser user);

  Future<UserProfile> fetch(String userId);

  Future<UserProfile> updateProfile(UserProfile profile);

  Future<UserProfile> updateSettings({
    required String userId,
    HealthGoal? goal,
    int? dailyStepGoal,
    bool? healthConnectSync,
    bool? autoSync,
    bool? wifiOnly,
  });

  Future<void> changePasswordDemo({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });
}
