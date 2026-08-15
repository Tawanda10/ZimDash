// Temporary end-to-end verification for the DoorDash-style features.
// Not part of the permanent suite — deleted after manual verification.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimdash/main.dart';

void main() {
  testWidgets('menu item sheet: qty stepper + notes + add to cart', (tester) async {
    await tester.pumpWidget(const ZimDashApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Gogo's Kitchen").first);
    await tester.pumpAndSettle();

    expect(find.text('⭐ Popular'), findsOneWidget);
    expect(find.text('Mains'), findsWidgets);
    expect(find.text('Drinks'), findsWidgets);

    await tester.tap(find.text('Sadza neNyama').first);
    await tester.pumpAndSettle();

    expect(find.text('Special instructions'), findsOneWidget);
    expect(find.textContaining('Add to order'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Add to order · \$13.00'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'no onions please');
    await tester.tap(find.textContaining('Add to order'));
    await tester.pumpAndSettle();

    expect(find.textContaining('no onions please'), findsOneWidget);
  });

  testWidgets('checkout: tip selector + promo code + place order + tracking summary', (tester) async {
    await tester.pumpWidget(const ZimDashApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Gogo's Kitchen").first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Add').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cart').first);
    await tester.pumpAndSettle();

    expect(find.text('Tip your rider'), findsOneWidget);
    await tester.tap(find.text('20%'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Promo code'), 'WELCOME10');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.textContaining('WELCOME10 applied'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Full name'), 'Tapiwa Test');
    await tester.enterText(find.widgetWithText(TextField, 'Phone'), '0771234567');
    await tester.enterText(find.widgetWithText(TextField, 'Street address'), '12 Sample Rd');

    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect(find.textContaining('On the way'), findsOneWidget);
    expect(find.text('Order summary'), findsOneWidget);
    expect(find.textContaining('12 Sample Rd'), findsOneWidget);
    expect(find.textContaining('WELCOME10'), findsWidgets);
  });

  testWidgets('orders screen: history + reorder', (tester) async {
    await tester.pumpWidget(const ZimDashApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Gogo's Kitchen").first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Add').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cart').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Full name'), 'Tapiwa Test');
    await tester.enterText(find.widgetWithText(TextField, 'Phone'), '0771234567');
    await tester.enterText(find.widgetWithText(TextField, 'Street address'), '12 Sample Rd');
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    expect(find.textContaining("Gogo's Kitchen"), findsWidgets);
    expect(find.text('Reorder'), findsOneWidget);

    await tester.tap(find.text('Reorder'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Added'), findsOneWidget);
  });

  testWidgets('theme picker offers Light/Dark/System', (tester) async {
    await tester.pumpWidget(const ZimDashApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.brightness_auto_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
