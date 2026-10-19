import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/widgets/notifications_widget.dart';

void main() {
  testWidgets('NotificationsWidget renders correctly with layout styling', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: NotificationsWidget()),
      ),
    ));

    expect(find.text('Notifications'), findsOneWidget);
    final titleText = tester.widget<Text>(find.text('Notifications'));
    expect(titleText.style?.fontSize, 20);

    // Assert Card styling (kills elevation: 0, borderRadius: 12, alpha: 0.2)
    final card = tester.widget<Card>(find.byType(Card).first);
    expect(card.elevation, 0);
    final shape = card.shape as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(12));
    expect(shape.side.color.a, closeTo(0.2, 0.01));

    // Assert padding (kills 16.0)
    expect(find.byWidgetPredicate((w) => w is Padding && w.padding == const EdgeInsets.all(16.0)), findsWidgets);

    // Assert SizedBox heights (kills 16, 8)
    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    expect(sizedBoxes.where((box) => box.height == 16).length, greaterThanOrEqualTo(2));
    expect(sizedBoxes.where((box) => box.height == 8).length, greaterThanOrEqualTo(2));
    expect(sizedBoxes.where((box) => box.width == 16).length, greaterThanOrEqualTo(4));

    // Inspect first item (_buildNotificationItem)
    expect(find.byWidgetPredicate((w) => w is Padding && w.padding == const EdgeInsets.symmetric(vertical: 8.0)), findsWidgets);

    // Assert Container colors and alpha
    final containers = tester.widgetList<Container>(find.byType(Container)).toList();
    expect(containers.length, greaterThanOrEqualTo(4));
    
    // Check specific alphas
    expect(containers.where((c) {
      if (c.decoration is BoxDecoration) {
        final color = (c.decoration as BoxDecoration).color;
        return color != null && (color.a - 0.1).abs() < 0.01; // withValues(alpha: 0.1)
      }
      return false;
    }).length, 4);

    // Assert Dividers
    expect(find.byType(Divider), findsNWidgets(2));

    // Restore text checks
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);
    expect(find.textContaining('Richard Jones', findRichText: true), findsOneWidget);
    expect(find.textContaining('blue t-shirt', findRichText: true), findsOneWidget);
    expect(find.textContaining('\$79.00', findRichText: true), findsOneWidget);
    expect(find.textContaining('\$2500.00', findRichText: true), findsOneWidget);
    expect(find.textContaining('Keyser Wick', findRichText: true), findsOneWidget);
    expect(find.textContaining('\$59.00', findRichText: true), findsOneWidget);
    expect(find.textContaining('Jane Davis', findRichText: true), findsOneWidget);

    // Assert container sizing
    final firstContainer = tester.widget<Container>(find.byType(Container).first);
    expect(firstContainer.constraints?.maxWidth, 40);
    expect(firstContainer.constraints?.maxHeight, 40);
    final boxDec = firstContainer.decoration as BoxDecoration;
    expect(boxDec.borderRadius, BorderRadius.circular(20));

    // Assert Icons
    expect(find.byIcon(Icons.attach_money), findsNWidgets(2));
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pump();
  });
}

