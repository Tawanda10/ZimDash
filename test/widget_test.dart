// Basic smoke test: the app boots and shows the home screen's hero heading.

import 'package:flutter_test/flutter_test.dart';

import 'package:zimdash/main.dart';

void main() {
  testWidgets('ZimDash boots to the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ZimDashApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Hot plates'), findsOneWidget);
    expect(find.text('All restaurants'), findsOneWidget);
  });
}
