import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/healthpal_theme.dart';
import '../../../theme/healthpal_brand.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_user.dart';
import '../application/profile_controller.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    required this.authController,
    required this.repository,
    required this.user,
  });

  final AuthController authController;
  final ProfileRepository repository;
  final AuthUser user;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late ProfileController _profile;
  final _name = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _steps = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  HealthGoal _goal = HealthGoal.maintainHealth;
  bool _healthConnectSync = false;
  bool _autoSync = true;
  bool _wifiOnly = false;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    widget.repository.ensure(widget.user);
    _profile = ProfileController(
      repository: widget.repository,
      userId: widget.user.id,
    )..addListener(_onChanged);
    unawaited(_profile.load());
  }

  @override
  void didUpdateWidget(covariant ProfileSettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id ||
        oldWidget.repository != widget.repository) {
      _profile
        ..removeListener(_onChanged)
        ..dispose();
      _createController();
    }
  }

  void _onChanged() {
    if (!mounted) return;
    final profile = _profile.profile;
    if (profile != null && !_profile.isSaving) _syncFields(profile);
    setState(() {});
  }

  void _syncFields(UserProfile profile) {
    if (_name.text != profile.user.name) _name.text = profile.user.name;
    _birthDate = profile.birthDate;
    _gender = profile.gender;
    _goal = profile.goal;
    _healthConnectSync = profile.healthConnectSync;
    _autoSync = profile.autoSync;
    _wifiOnly = profile.wifiOnly;
    _steps.text = '${profile.dailyStepGoal}';
    _height.text = profile.heightCm?.toStringAsFixed(0) ?? '';
    _weight.text = profile.weightKg?.toStringAsFixed(1) ?? '';
  }

  @override
  void dispose() {
    _profile
      ..removeListener(_onChanged)
      ..dispose();
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    _steps.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _name.text.trim();
    final height = double.tryParse(_height.text.trim());
    final weight = double.tryParse(_weight.text.trim());
    if (name.isEmpty) {
      _showMessage('Họ tên không được để trống.');
      return;
    }
    if (_height.text.trim().isNotEmpty && (height == null || height <= 0)) {
      _showMessage('Chiều cao phải là số lớn hơn 0.');
      return;
    }
    if (_weight.text.trim().isNotEmpty && (weight == null || weight <= 0)) {
      _showMessage('Cân nặng phải là số lớn hơn 0.');
      return;
    }
    final current = _profile.profile;
    if (current == null) return;
    final saved = await _profile.save(
      current.copyWith(
        user: AuthUser(
          id: widget.user.id,
          name: name,
          email: widget.user.email,
        ),
        birthDate: _birthDate,
        clearBirthDate: _birthDate == null,
        gender: _gender,
        clearGender: _gender == null,
        heightCm: height,
        clearHeight: height == null,
        weightKg: weight,
        clearWeight: weight == null,
      ),
    );
    if (!mounted) return;
    if (saved) {
      widget.authController.updateDisplayName(name);
      _showMessage('Đã lưu hồ sơ.');
    } else {
      _showMessage('Chưa thể lưu hồ sơ. Vui lòng thử lại.');
    }
  }

  Future<void> _updateSettings() async {
    final steps = int.tryParse(_steps.text.trim());
    if (steps == null || steps < 100) {
      _showMessage('Mục tiêu bước phải từ 100 bước trở lên.');
      return;
    }
    final saved = await _profile.updateSettings(
      goal: _goal,
      dailyStepGoal: steps,
      healthConnectSync: _healthConnectSync,
      autoSync: _autoSync,
      wifiOnly: _wifiOnly,
    );
    if (mounted) {
      _showMessage(
        saved ? 'Đã cập nhật mục tiêu và đồng bộ.' : 'Chưa thể cập nhật.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      initialDate: _birthDate ?? DateTime(2000),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _showPasswordSheet() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Đổi mật khẩu',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                _passwordField(
                  'Mật khẩu hiện tại',
                  current,
                  'profile-current-password',
                ),
                const SizedBox(height: 12),
                _passwordField('Mật khẩu mới', next, 'profile-new-password'),
                const SizedBox(height: 12),
                _passwordField(
                  'Xác nhận mật khẩu mới',
                  confirm,
                  'profile-confirm-password',
                ),
                const SizedBox(height: 18),
                FilledButton(
                  key: const Key('profile-change-password-submit'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await _profile.changePasswordDemo(
                      currentPassword: current.text,
                      newPassword: next.text,
                    );
                    if (context.mounted) Navigator.of(context).pop(ok);
                  },
                  child: const Text('Cập nhật mật khẩu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    current.dispose();
    next.dispose();
    confirm.dispose();
    if (result == true && mounted) {
      _showMessage('Tính năng demo, chưa thay đổi mật khẩu thật.');
    }
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    String key,
  ) {
    return TextFormField(
      key: Key(key),
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.length < 8
          ? 'Mật khẩu tối thiểu 8 ký tự.'
          : null,
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text(
          'Bạn có thể đăng nhập lại bằng tài khoản này trong phiên hiện tại.',
        ),
        actions: [
          TextButton(
            key: const Key('profile-cancel-logout'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            key: const Key('profile-confirm-logout'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await widget.authController.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile.profile;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFC4C5), Color(0xFFDCCEFF)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _profile.isLoading && profile == null
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    key: const Key('profile-screen'),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        sliver: SliverToBoxAdapter(child: _header()),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: _personalCard(profile),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        sliver: SliverToBoxAdapter(child: _goalsCard(profile)),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        sliver: SliverToBoxAdapter(child: _syncCard(profile)),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        sliver: SliverToBoxAdapter(child: _securityCard()),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        sliver: SliverToBoxAdapter(child: _aboutCard()),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hồ sơ & cài đặt',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Cá nhân hóa HealthPal theo cách của bạn.',
              style: TextStyle(fontSize: 13, color: HealthPalColors.secondary),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          shape: BoxShape.circle,
        ),
        child: const HealthPalLogo(size: 48, borderRadius: 24),
      ),
    ],
  );

  Widget _card({required Widget child}) => Container(
    padding: EdgeInsets.zero,
    child: Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x2412162E),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    ),
  );

  Widget _sectionTitle(IconData icon, String title) => Row(
    children: [
      Icon(icon, color: HealthPalColors.blue, size: 20),
      const SizedBox(width: 9),
      Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ],
  );

  Widget _personalCard(UserProfile? profile) => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(CupertinoIcons.person_fill, 'Thông tin cá nhân'),
        const SizedBox(height: 16),
        TextField(
          key: const Key('profile-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Họ và tên'),
        ),
        const SizedBox(height: 12),
        InkWell(
          key: const Key('profile-birth-date'),
          onTap: _pickBirthDate,
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Ngày sinh',
              suffixIcon: Icon(CupertinoIcons.calendar),
            ),
            child: Text(
              _birthDate == null
                  ? 'Chưa cập nhật'
                  : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const Key('profile-gender'),
          initialValue: _gender,
          decoration: const InputDecoration(labelText: 'Giới tính'),
          items: const [
            DropdownMenuItem(value: 'Nam', child: Text('Nam')),
            DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
            DropdownMenuItem(value: 'Khác', child: Text('Khác')),
          ],
          onChanged: (value) => setState(() => _gender = value),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('profile-height'),
                controller: _height,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Chiều cao (cm)'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                key: const Key('profile-weight'),
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('profile-save'),
          onPressed: _profile.isSaving ? null : _saveProfile,
          child: _profile.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu thay đổi'),
        ),
      ],
    ),
  );

  Widget _goalsCard(UserProfile? profile) => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(CupertinoIcons.flag_fill, 'Mục tiêu sức khỏe'),
        const SizedBox(height: 14),
        DropdownButtonFormField<HealthGoal>(
          key: const Key('profile-goal'),
          initialValue: _goal,
          decoration: const InputDecoration(labelText: 'Mục tiêu'),
          items: HealthGoal.values
              .map(
                (goal) =>
                    DropdownMenuItem(value: goal, child: Text(goal.label)),
              )
              .toList(),
          onChanged: (value) => setState(() => _goal = value ?? _goal),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('profile-step-goal'),
          controller: _steps,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Mục tiêu bước mỗi ngày',
            suffixText: 'bước',
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          key: const Key('profile-save-goals'),
          onPressed: _profile.isSaving ? null : _updateSettings,
          child: const Text('Lưu mục tiêu'),
        ),
      ],
    ),
  );

  Widget _syncCard(UserProfile? profile) => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(CupertinoIcons.arrow_2_circlepath, 'Đồng bộ dữ liệu'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              CupertinoIcons.heart_circle_fill,
              color: Color(0xFFE04B59),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Connect',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile?.healthConnectStatus.label ?? 'Chưa kết nối',
                    style: const TextStyle(
                      fontSize: 12,
                      color: HealthPalColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              key: const Key('profile-health-connect'),
              onPressed: () => _showMessage(
                'Health Connect đang ở chế độ demo, chưa mở quyền native.',
              ),
              child: const Text('Quản lý'),
            ),
          ],
        ),
        SwitchListTile(
          key: const Key('profile-sync-health'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Đồng bộ Health Connect'),
          value: _healthConnectSync,
          onChanged: (value) {
            setState(() => _healthConnectSync = value);
            _updateSettings();
          },
        ),
        SwitchListTile(
          key: const Key('profile-sync-auto'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Tự động đồng bộ'),
          value: _autoSync,
          onChanged: (value) {
            setState(() => _autoSync = value);
            _updateSettings();
          },
        ),
        SwitchListTile(
          key: const Key('profile-sync-wifi'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Chỉ đồng bộ khi dùng Wi‑Fi'),
          value: _wifiOnly,
          onChanged: (value) {
            setState(() => _wifiOnly = value);
            _updateSettings();
          },
        ),
      ],
    ),
  );

  Widget _securityCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(CupertinoIcons.lock_fill, 'Bảo mật'),
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('profile-change-password'),
          onPressed: _showPasswordSheet,
          child: const Text('Đổi mật khẩu'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const Key('profile-logout'),
          onPressed: _profile.isSaving ? null : _logout,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB3263A),
          ),
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );

  Widget _aboutCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(CupertinoIcons.info_circle_fill, 'Về HealthPal'),
        const SizedBox(height: 12),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Phiên bản'),
          trailing: Text('1.0.0+1'),
        ),
        const Divider(height: 1),
        const SizedBox(height: 12),
        const Text(
          'Thông tin sức khỏe chỉ mang tính tham khảo, không thay thế tư vấn hoặc chẩn đoán y tế.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: HealthPalColors.secondary,
          ),
        ),
      ],
    ),
  );
}
