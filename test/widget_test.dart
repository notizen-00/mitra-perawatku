import 'package:flutter_test/flutter_test.dart';
import 'package:mitra_perawatku/app.dart';

void main() {
  testWidgets('app loads with Perawatku Mitra home screen', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Perawatku Mitra'), findsOneWidget);
    expect(find.text('Siap menerima layanan kesehatan'), findsOneWidget);
  });
}
