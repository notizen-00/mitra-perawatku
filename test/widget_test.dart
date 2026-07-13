import 'package:flutter_test/flutter_test.dart';
import 'package:mitra_perawatku/app.dart';
import 'package:mitra_perawatku/core/di/injection_container.dart';

void main() {
  testWidgets('app loads with Mitra login screen', (tester) async {
    await init();
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.text('Masuk Mitra'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Daftar sebagai mitra'), findsOneWidget);
  });
}
