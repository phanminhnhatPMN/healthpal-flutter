import 'package:flutter/foundation.dart';

import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required this.repository, required this.userId});

  final ProfileRepository repository;
  final String userId;
  UserProfile? _profile;
  Object? _error;
  bool _loading = false;
  bool _saving = false;

  UserProfile? get profile => _profile;
  Object? get error => _error;
  bool get isLoading => _loading;
  bool get isSaving => _saving;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await repository.fetch(userId);
    } catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> save(UserProfile profile) async {
    if (_saving) return false;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await repository.updateProfile(profile);
      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<bool> updateSettings({
    HealthGoal? goal,
    int? dailyStepGoal,
    bool? healthConnectSync,
    bool? autoSync,
    bool? wifiOnly,
  }) async {
    if (_saving || _profile == null) return false;
    _saving = true;
    notifyListeners();
    try {
      _profile = await repository.updateSettings(
        userId: userId,
        goal: goal,
        dailyStepGoal: dailyStepGoal,
        healthConnectSync: healthConnectSync,
        autoSync: autoSync,
        wifiOnly: wifiOnly,
      );
      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<bool> changePasswordDemo({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_saving) return false;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await repository.changePasswordDemo(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
