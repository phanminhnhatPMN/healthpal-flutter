import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this._repository});

  final AuthRepository _repository;
  AuthUser? _user;
  AuthException? _error;
  bool _isBusy = false;
  bool _isDisposed = false;

  AuthUser? get user => _user;
  AuthException? get error => _error;
  bool get isBusy => _isBusy;

  Future<bool> signIn({required String email, required String password}) =>
      _run(() => _repository.signIn(email: email, password: password));

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) => _run(
    () => _repository.signUp(name: name, email: email, password: password),
  );

  Future<bool> signOut() => _run(() async {
    await _repository.signOut();
    return null;
  });

  void clearError() {
    if (_isDisposed || _error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<AuthUser?> Function() operation) async {
    if (_isDisposed || _isBusy) return false;
    _isBusy = true;
    _error = null;
    notifyListeners();

    try {
      final user = await operation();
      if (_isDisposed) return false;
      _user = user;
      return true;
    } on AuthException catch (error) {
      if (!_isDisposed) _error = error;
      return false;
    } catch (_) {
      if (!_isDisposed) _error = const AuthException(AuthFailure.unknown);
      return false;
    } finally {
      if (!_isDisposed) {
        _isBusy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isBusy = false;
    super.dispose();
  }
}
