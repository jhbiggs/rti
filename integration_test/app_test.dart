import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:rti/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('log in with teacher', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      //
      expect(find.text('Email'), findsOneWidget);

      //finds the floating action button to tap on.
      final Finder fab = find.byTooltip('Increment');

      //emulate a tap on the floating action button.
      await tester.tap(fab);

      //trigger a frame
      await tester.pumpAndSettle();

      //verify the counter increments by one.
      expect(find.text('1'), findsOneWidget);
    });
  });
}
