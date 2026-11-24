import 'package:flutter_test/flutter_test.dart';
import 'package:larisch_app/core/router/app_routes.dart';

void main() {
  test('AppRoutes defines core onboarding and tab routes', () {
    expect(AppRoutes.splash, '/splash');
    expect(AppRoutes.welcome, '/welcome');
    expect(AppRoutes.beranda, '/beranda');
    expect(AppRoutes.transaksi, '/transaksi');
    expect(AppRoutes.laporan, '/laporan');
    expect(AppRoutes.profil, '/profil');
  });
}
