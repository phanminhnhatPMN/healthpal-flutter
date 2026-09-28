import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthpal/app.dart';
import 'package:healthpal/features/auth/data/demo_auth_repository.dart';
import 'package:healthpal/features/history/data/demo_health_history_repository.dart';
import 'package:healthpal/features/profile/data/demo_profile_repository.dart';

Finder keyed(String value) => find.byKey(ValueKey<String>(value));

Future<void> openProfile(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    HealthPalApp(
      authRepository: DemoAuthRepository(latency: Duration.zero),
      historyRepository: DemoHealthHistoryRepository(latency: Duration.zero),
      profileRepository: DemoProfileRepository(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(keyed('fill-demo'));
  await tester.pumpAndSettle();
  await tester.tap(keyed('login-submit'));
  await tester.pumpAndSettle();
  await tester.tap(keyed('nav-profile'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('profile tab loads, validates and saves profile data', (
    tester,
  ) async {
    await openProfile(tester);

    expect(keyed('profile-screen'), findsOneWidget);
    await tester.enterText(keyed('profile-name'), 'Nguyễn Minh Anh');
    await tester.enterText(keyed('profile-height'), '170');
    await tester.enterText(keyed('profile-weight'), '65');
    await tester.tap(keyed('profile-save'));
    await tester.pumpAndSettle();
    expect(find.text('Đã lưu hồ sơ.'), findsOneWidget);
  });

  testWidgets('profile sync controls and demo password sheet are available', (
    tester,
  ) async {
    await openProfile(tester);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -620));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đồng bộ Health Connect'));
    await tester.pumpAndSettle();
    await tester.tap(keyed('profile-health-connect'));
    await tester.pumpAndSettle();
    expect(find.textContaining('đang ở chế độ demo'), findsOneWidget);

    await tester.tap(keyed('profile-change-password'));
    await tester.pumpAndSettle();
    expect(keyed('profile-change-password-submit'), findsOneWidget);
    await tester.tap(keyed('profile-change-password-submit'));
    await tester.pumpAndSettle();
    expect(find.text('Mật khẩu tối thiểu 8 ký tự.'), findsWidgets);
  });
}
