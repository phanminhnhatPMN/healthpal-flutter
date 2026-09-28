# HealthPal

Ứng dụng Flutter bằng tiếng Việt gồm luồng tài khoản demo, màn History & Analytics và Profile & Settings. Giao diện dùng phong cách hồng–tím, thẻ trắng bo tròn; ưu tiên Android và hỗ trợ màn hình nhỏ, cỡ chữ lớn.

## Chạy ứng dụng

```sh
flutter pub get
flutter run
```

Tài khoản mẫu: **demo@healthpal.app** / **HealthPal123**. Nút **Điền tài khoản mẫu** điền sẵn thông tin, sau đó bấm **Đăng nhập**.

Đăng ký hoặc đăng nhập thành công mở shell gồm hai tab **Lịch sử** và **Hồ sơ**. Lịch sử có dữ liệu demo 7/30 ngày, biểu đồ Stress, Giấc ngủ, Số bước, Nhịp tim nghỉ, HRV và Calories vận động. Chạm một ngày để xem health summary trong bottom sheet. Hồ sơ cho phép cập nhật thông tin cá nhân, mục tiêu bước, mục tiêu sức khỏe và các tùy chọn đồng bộ.

Đăng xuất có xác nhận; có thể đăng nhập lại bằng tài khoản vừa tạo trong cùng phiên chạy. Khi khởi động lại ứng dụng, tài khoản mới và phiên đăng nhập được đặt lại.

Đây là bản demo: chỉ dùng thông tin mẫu. Thông tin đăng ký, hồ sơ, cài đặt và lịch sử sức khỏe nằm trong bộ nhớ của tiến trình, không ghi vào thiết bị hoặc gửi lên máy chủ. Health Connect và đổi mật khẩu hiện chỉ có giao diện mô phỏng, chưa kết nối native/backend.

## Cấu trúc

- `lib/app.dart`: khởi tạo ứng dụng và vòng đời bộ điều khiển tài khoản.
- `lib/theme/`: màu sắc và kiểu giao diện dùng chung.
- `lib/features/auth/domain/`: thông tin người dùng.
- `lib/features/auth/data/`: hợp đồng AuthRepository và bản demo lưu trong bộ nhớ.
- `lib/features/auth/application/`: AuthController, trạng thái xử lý và lỗi.
- `lib/features/auth/presentation/`: đăng nhập, đăng ký, tài khoản và thành phần dùng chung.
- `lib/features/history/domain/`: health summary, khoảng thời gian, chỉ số và mức stress.
- `lib/features/history/data/`: hợp đồng repository và bộ dữ liệu demo 30 ngày.
- `lib/features/history/application/`: trạng thái tải, khoảng thời gian và chỉ số đang chọn.
- `lib/features/history/presentation/`: màn History & Analytics, biểu đồ và chi tiết ngày.
- `lib/features/home/presentation/`: shell và thanh điều hướng giữa Lịch sử/Hồ sơ.
- `lib/features/profile/domain/`: hồ sơ, mục tiêu và trạng thái Health Connect demo.
- `lib/features/profile/data/`: hợp đồng ProfileRepository và bản demo lưu trong bộ nhớ.
- `lib/features/profile/application/`: ProfileController cho tải/lưu hồ sơ và cài đặt.
- `lib/features/profile/presentation/`: màn Profile & Settings, đổi mật khẩu demo và đăng xuất.

Để nối backend sau này, triển khai `AuthRepository`, `HealthHistoryRepository` và `ProfileRepository`, rồi truyền vào `HealthPalApp`. Giao diện không phụ thuộc trực tiếp vào HTTP, Health Connect hoặc cách lưu phiên.

## Kiểm tra

```sh
flutter analyze
flutter test
flutter build apk --debug
```

Kiểm tra trên Android và chụp các màn hình (thay mã thiết bị nếu cần):

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/auth_flow_test.dart -d emulator-5554
```

Ảnh kiểm tra được lưu tại `build/auth_screenshots/`. Bản APK debug được tạo tại `build/app/outputs/flutter-apk/app-debug.apk`.
