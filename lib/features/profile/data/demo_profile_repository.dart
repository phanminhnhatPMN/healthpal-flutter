import '../../auth/domain/auth_user.dart';
import '../domain/user_profile.dart';
import 'profile_repository.dart';

class DemoProfileRepository implements ProfileRepository {
  DemoProfileRepository({this.latency = Duration.zero});

  final Duration latency;
  final Map<String, UserProfile> _profiles = {};

  Future<void> _wait() => Future<void>.delayed(latency);

  UserProfile _default(AuthUser user) => UserProfile(
    user: user,
    healthConnectStatus: HealthConnectStatus.disconnected,
  );

  @override
  Future<UserProfile> fetch(String userId) async {
    await _wait();
    final profile = _profiles[userId];
    if (profile == null) {
      throw StateError('Profile not found');
    }
    return profile;
  }

  @override
  void ensure(AuthUser user) {
    _profiles.putIfAbsent(user.id, () => _default(user));
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _wait();
    _profiles[profile.user.id] = profile;
    return profile;
  }

  @override
  Future<UserProfile> updateSettings({
    required String userId,
    HealthGoal? goal,
    int? dailyStepGoal,
    bool? healthConnectSync,
    bool? autoSync,
    bool? wifiOnly,
  }) async {
    await _wait();
    final current = _profiles[userId];
    if (current == null) throw StateError('Profile not found');
    final updated = current.copyWith(
      goal: goal,
      dailyStepGoal: dailyStepGoal,
      healthConnectSync: healthConnectSync,
      autoSync: autoSync,
      wifiOnly: wifiOnly,
    );
    _profiles[userId] = updated;
    return updated;
  }

  @override
  Future<void> changePasswordDemo({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _wait();
  }
}
