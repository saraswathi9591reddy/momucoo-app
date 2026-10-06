import 'package:flutter_test/flutter_test.dart';
import 'package:momucoo/router.dart';

void main() {
  test('logged-out user is sent to login from protected routes', () {
    expect(sessionRedirect(Routes.dashboard, false), Routes.login);
    expect(sessionRedirect(Routes.doctorReview, false), Routes.login);
    expect(sessionRedirect(Routes.home, false), isNull);
    expect(sessionRedirect(Routes.register, false), isNull);
  });
  test('logged-in user skips auth pages', () {
    expect(sessionRedirect(Routes.login, true), Routes.dashboard);
    expect(sessionRedirect(Routes.reports, true), isNull);
  });
}
