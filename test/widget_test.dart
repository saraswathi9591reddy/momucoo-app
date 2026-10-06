import 'package:flutter_test/flutter_test.dart';
import 'package:momucoo/core/storage.dart';
import 'package:momucoo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots to Home when logged out', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppStorage.init();
    await tester.pumpWidget(const MomucooApp());
    await tester.pumpAndSettle();
    expect(find.text('Pregnancy care, but make it simple.'), findsOneWidget);
  });

  test('storage keeps web key names and session raw string', () async {
    SharedPreferences.setMockInitialValues({'momucooSession': 'true', 'cbcData': '{"hb":"10"}'});
    final s = await AppStorage.init();
    expect(s.isLoggedIn, true);
    expect(s.cbcData!['hb'], '10');
    await s.setLoggedIn(false);
    expect(s.getRaw('momucooSession'), isNull);
  });
}
